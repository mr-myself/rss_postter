require 'sqlite3'
require 'active_record'
require 'rss'
require 'yaml'
require 'twitter'
require 'sinatra/config_file'
require Dir::pwd + '/model_module'

include Model

Settings = YAML.load_file(Dir::pwd + '/config.yml')

def rss_parse(url)
  url = "http://" + url unless url.match(/http:\/\//)
  rss = RSS::Parser.parse(url)
end

def send_rss(title, link, accounts)
  Twitter.configure do |config|
    config.consumer_key = Settings['twitter']['key']
    config.consumer_secret = Settings['twitter']['secret']
    config.oauth_token = Settings['twitter']['oauth_token']
    config.oauth_token_secret = Settings['twitter']['oauth_token_secret']
  end

  accounts.each do |account|
    mention = "@#{account} \"#{title}\" #{link}"
    client = Twitter::Client.new
    client.update(mention)
  end
end


users = User.all
rsses = Rss.all

rsses.each do |rss|
  content = rss_parse(rss[:url])
  latest = content.items[0]
  next if rss[:title] == latest.title

  accounts = rss.users.pluck(:account)
  send_rss(latest.title, latest.link, accounts)
  Rss.update(rss[:id], :title => latest.title)
end
