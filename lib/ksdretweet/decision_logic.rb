require 'twitter'
require 'natto'
class DecisionLogic
  def initialize(ids)
    @ids = ids
  end

  def shoud_retweet?(tweet)
    return false if tweet.retweet?
    return false if tweet.source.include?('twittbot.net')
    return false if tweet.source.include?('twiroboJP')
    return false unless @ids.include?(tweet.user.id)

    if tweet.reply?
      return false unless @ids.include?(tweet.in_reply_to_user_id)
    end
    full_text = !tweet.attrs[:extended_tweet].nil? ? tweet.attrs[:extended_tweet][:full_text] : tweet.text
    return include_word?(full_text)
  end

  def include_word? (text)
    return false if text.include?('ksdretweet')

    if text.include?('あいな')
      return false if text.include?('あいなぷぅ')

      if text.include?('相羽')
        return true if text.include?('楠田')

        return false
      end
      if text.include?('鈴木')
        return true if text.include?('楠田')

        return false
      end
      if text.include?('あいななごはん')
        return true if text.include?('楠田')

        return false
      end
      nm = Natto::MeCab.new
      nm.parse(text) do |n|
        return true if n.surface == 'あいな'
      end
    end
    if text.include?('くっすん')
      if text.include?('楠雄二朗')
        return true if text.include?('楠田')

        return false
      end
      return true
    end
    include_word_list = %w[楠田 亜衣奈 くすリル kusudaaina]
    include_word_list.each do |word|
      return true if text.include?(word)
    end
    return false
  end
end
