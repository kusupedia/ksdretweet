require 'twitter'
require 'yaml'

def isIncludeWord (tweet,my_user)
   return false if tweet.user.screen_name == my_user.screen_name
   rp1 = Regexp.new("^RT*")
   return false if rp1 =~ tweet.text
   return false if tweet.source.include?("twittbot.net")
   if tweet.text.include?("あいな") then
      if tweet.text.include?("相羽") then
         return true if tweet.text.include?("楠田")
         return false
      end
      return true
   end
   includeWordList = ["楠田","亜衣奈","くっすん","くすリル","kusudaaina"]
   includeWordList.each do|word|
      return true if tweet.text.include?(word)
   end
   return false
end

#account_config = YAML.load_file("youraccount.yml")
account_config = YAML.load_file("/usr/local/etc/twitter/ksdretweet.yml")

rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = account_config["consumer_key"]
  config.consumer_secret     = account_config["consumer_secret"]
  config.access_token        = account_config["access_token"]
  config.access_token_secret = account_config["access_token_secret"]
end

streaming_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = account_config["consumer_key"]
  config.consumer_secret     = account_config["consumer_secret"]
  config.access_token        = account_config["access_token"]
  config.access_token_secret = account_config["access_token_secret"]
end

my_user = rest_client.user 

streaming_client.user do |object|
  if object.is_a?(Twitter::Tweet)
     rest_client.retweet(object.id) if isIncludeWord(object,my_user)
  end
end

