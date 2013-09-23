require 'sinatra/base'
require 'sinatra/config_file'
require 'slim'
require 'sqlite3'
require 'oauth'
require 'omniauth-twitter'
require './model_module'
require 'rss'

include Model

ActiveRecord::Base.configurations = YAML.load_file('config.yml')

class RssPost < Sinatra::Base
  register Sinatra::ConfigFile
  config_file File.dirname( __FILE__ ) + '/config.yml'

  configure do
    use Rack::Session::Cookie,
      :expire => 1 * 60 * 60 * 24 * 7,
      :secret => Digest::SHA1.hexdigest(rand.to_s)

    KEY = settings.twitter[:key]
    SECRET = settings.twitter[:secret]

    use OmniAuth::Builder do
      provider :twitter, KEY, SECRET
    end
  end

  before do
    unless request.path_info =~ /^\/login/
      pass if request.path_info =~ /^\/auth\//
      redirect to('/login') unless current_user
    end
  end

  get '/login' do
    slim :login
  end

  get '/auth/twitter/callback' do
    account = env['omniauth.auth'].info.nickname
    user = User.where(:account => account).first

    unless user
      user = User.create(:account => account)
    end
    session[:user] = user
    redirect to('/')
  end

  get '/auth/failure' do
    return 500
  end

  get '/' do
    slim :index
  end

  get '/api/list' do
    rss_list = User.where(:id => session[:user].id).first.rsses
    return rss_list.to_json
  end

  delete %r{/api/list/([0-9]*)} do
    id = params[:captures].first
    ActiveRecord::Base.transaction do
      Rss.delete(id)
      ho = UserRssMap.delete_all(
        :user_id => session[:user].id,
        :rss_id  => id
      )
    end
    return {:result => 'success'}.to_json
  end

  post '/register' do
    url = params['url']
    result = url_validate(url)
    redirect '/' and return unless result

    data = {
      :title => nil,
      :url   => url
    }
    exist = Rss.where(:url => data[:url]).first
    if exist
      UserRssMap.create(
        :user_id => session[:user].id,
        :rss_id  => exist[:id]
      )
    else
      new = Rss.create(data)
      UserRssMap.create(
        :user_id => session[:user].id,
        :rss_id  => new[:id]
      )
    end
    redirect '/'
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  def current_user
    !session[:user].nil?
  end

  private
    def url_validate(url)
      valid = valid_url?(url)
      deplicate = undeplicate?(url)
      return valid && deplicate ? true : false
    end

    def valid_url?(url)
      url = "http://" + url unless url.match(/http:\/\//)
      result = false
      begin
        result = RSS::Parser.parse(url)
        result = true
      rescue => e
        p e.message
      end

      return result
    end

    def undeplicate?(url)
      exist = Rss.where(:url => url).first
      exist = exist.users.where(:id => session[:user].id) if exist
      return exist.blank? ? true : false
    end

end
