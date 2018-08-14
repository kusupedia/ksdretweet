require 'twitter'
require 'yaml'
require 'logger'
require 'ksdretweet/decision_logic'

class Ksdretweet
    def initialize
        @logger = Logger.new("/var/log/ruby/ksdretweet_logger.log",16)
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
        @ids = @rest_client.friend_ids("ksdretweet")
        @decision_logic = DecisionLogic.new(@ids)
    end
    def run
        @streaming_client.filter(follow:@ids.entries.join(",")) do |object|
            if object.is_a?(Twitter::Tweet)
                @rest_client.update(object.id) if @decision_logic.shoud_retweet?(object)
		@logger.info(object.id)
            end
            if object.is_a?(Twitter::Streaming::StallWarning)
                @logger.warn(object.message)
            end
        end
    end
end
