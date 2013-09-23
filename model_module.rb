module Model
  require 'active_record'

  # TODO: 環境変数適宜変えれないの？
  ActiveRecord::Base.configurations = YAML.load_file('database.yml')
  ActiveRecord::Base.establish_connection('development')

  class User < ActiveRecord::Base
    has_many :user_rss_maps
    has_many :rsses, :through => :user_rss_maps
  end

  class Rss < ActiveRecord::Base
    has_many :user_rss_maps
    has_many :users, :through => :user_rss_maps
  end

  class UserRssMap < ActiveRecord::Base
    belongs_to :user
    belongs_to :rss
  end

end
