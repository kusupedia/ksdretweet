require 'twitter'
require 'yaml'
require 'ksdretweet/decision_logic'

class Ksdretweet
    def initialize
        #account_config = YAML.load_file("ksdretweet/youraccount.yml")
        account_config = YAML.load_file("/usr/local/etc/twitter/ksdretweet.yml")
        @rest_client = Twitter::REST::Client.new do |config|
            config.consumer_key        = account_config["consumer_key"]
            config.consumer_secret     = account_config["consumer_secret"]
            config.access_token        = account_config["access_token"]
            config.access_token_secret = account_config["access_token_secret"]
        end
        @streaming_client = Twitter::Streaming::Client.new do |config|
            config.consumer_key        = account_config["consumer_key"]
            config.consumer_secret     = account_config["consumer_secret"]
            config.access_token        = account_config["access_token"]
            config.access_token_secret = account_config["access_token_secret"]
        end
        @my_user = @rest_client.user
        @decision_logic = DecisionLogic.new
    end
    def run
        @streaming_client.user do |object|
            if object.is_a?(Twitter::Tweet)
                @rest_client.retweet(object.id) if shoud_retweet?(object)
            end
        end
    end
    def shoud_retweet?(tweet)
        return false if tweet.user.screen_name == @my_user.screen_name
        return false if tweet.source.include?("twittbot.net")
        return @decision_logic.include_word?(tweet.text)
    end
end
