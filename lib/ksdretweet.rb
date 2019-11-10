# frozen_string_literal: true

require 'twitter'
require 'yaml'
require 'logger'
require 'aws-sdk'
require 'ksdretweet/decision_logic'
require 'ksdretweet/image_url_message'

class Ksdretweet
  def initialize
    @logger = Logger.new('/var/log/ruby/ksdretweet_logger.log', 16)
    # account_config = YAML.load_file('ksdretweet/youraccount.yml')
    account_config = YAML.load_file('/usr/local/etc/twitter/ksdretweet.yml')
    @rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = account_config['consumer_key']
      config.consumer_secret     = account_config['consumer_secret']
      config.access_token        = account_config['access_token']
      config.access_token_secret = account_config['access_token_secret']
    end
    @streaming_client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = account_config['consumer_key']
      config.consumer_secret     = account_config['consumer_secret']
      config.access_token        = account_config['access_token']
      config.access_token_secret = account_config['access_token_secret']
    end
    @ids = @rest_client.friend_ids('ksdretweet')
    @decision_logic = DecisionLogic.new(@ids)

    @sqs = Aws::SQS::Client.new(region: 'ap-northeast-1')

    image_queue_name = 'image_analysis.fifo'
    @image_queue_url = @sqs.get_queue_url(queue_name: image_queue_name).queue_url
  end

  def run
    @streaming_client.filter(follow: @ids.entries.join(',')) do |object|
      if object.is_a?(Twitter::Tweet)
        if @decision_logic.shoud_retweet?(object)
          @rest_client.retweet(object.id)
        else
          image_url_message = ImageUrlMessage.new(object)
          if image_url_message.message?
            @sqs.send_message({
              queue_url: image_queue_url,
              message_group_id: '0',
              message_deduplication_id: object.id.to_s,
              message_body: image_url.message,
              message_attributes: {}
            })
          end
        end
        @logger.info(object.id)
      end
      if object.is_a?(Twitter::Streaming::StallWarning)
        @logger.warn(object.message)
      end
    end
  end
end
