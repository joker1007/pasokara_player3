# _*_ coding: utf-8 _*_
require "twitter"
require "yaml"
require "singleton"


module Notifier
  class Twitter
    include Singleton

    def initialize
      begin
        setting = YAML.load_file(File.join(File.dirname(__FILE__), "twitter.yml"))
        twitter_consumer_key = setting["consumer_key"]
        twitter_consumer_secret = setting["consumer_secret"]
        twitter_auth_key = setting["auth_key"]
        twitter_auth_secret = setting["auth_secret"]
        oauth = ::Twitter::OAuth.new(twitter_consumer_key, twitter_consumer_secret)
        oauth.authorize_from_access(twitter_auth_key, twitter_auth_secret)
        @@twitter = ::Twitter::Base.new(oauth)
      rescue Exception
        @@twitter = nil
        puts "Tweet Failed."
      end
    end

    def play_notify(name)
      begin
        @@twitter.update("歌ってるなう: " + File.basename(name, ".*"))
      rescue Exception
        puts "Notify Failed"
      end
    end

    def queue_notify(name)
    end
  end
end
