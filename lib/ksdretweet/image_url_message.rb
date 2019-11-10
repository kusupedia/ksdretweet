# frozen_string_literal: true

require 'twitter'
require 'json'

class ImageUrlMessage
  attr_reader :message

  def initialize(tweet)
    urls = []
    if tweet.attrs[:extended_tweet].nil?
      tweet.media.each do |media|
        urls << media.media_uri_https
      end
    else
      unless tweet.attrs[:extended_tweet][:entities][:media]&.nil?
        tweet.attrs[:extended_tweet][:entities][:media].each do |media|
          urls << media[:media_url_https]
        end
      end
    end
    if urls.empty?
      @message = nil
    else
      message_hash = { id: tweet.id, image_urls: urls }
      @message = JSON.generate(message_hash)
    end
  end

  def message?
    !@message.nil?
  end
end
