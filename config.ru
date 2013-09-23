require 'rubygems' unless defined? ::Gem
require File.dirname( __FILE__ ) + '/rss_post'

require 'sinatra/reloader'
Sinatra.register Sinatra::Reloader


run RssPost
