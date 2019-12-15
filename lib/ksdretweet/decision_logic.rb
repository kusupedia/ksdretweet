# frozen_string_literal: true

require 'twitter'
require 'natto'
class DecisionLogic
  def initialize(ids)
    @ids = ids
  end

  def shoud_retweet?(tweet)
    full_text = if tweet.attrs[:extended_tweet].nil?
                  tweet.text
                else
                  tweet.attrs[:extended_tweet][:full_text]
                end
    include_word?(full_text)
  end

  def include_word?(text)
    return false if text.include?('ksdretweet')

    if text.include?('あいな')
      return false if text.include?('あいなぷぅ')

      exclude_word_list = %w[相羽 鈴木 あいななごはん らぶりーあいなちゃん]
      exclude_word_list.each do |exclude_word|
        if text.include?(exclude_word)
          return true if text.include?('楠田')

          return false
        end
      end
      nm = Natto::MeCab.new
      nm.parse(text) do |n|
        return true if n.surface == 'あいな'
      end
    end

    if text.include?('くっすん')
      exclude_word_list = %w[楠雄二朗]
      exclude_word_list.each do |exclude_word|
        if text.include?(exclude_word)
          return true if text.include?('楠田')

          return false
        end
      end

      return true
    end

    if text.include?('楠田')
      exclude_word_list = %w[敏之]
      exclude_word_list.each do |exclude_word|
        if text.include?(exclude_word)
          return true if text.include?('亜衣奈')

          return false
        end
      end

      return true
    end

    include_word_list = %w[亜衣奈 くすリル kusudaaina]
    include_word_list.each do |word|
      return true if text.include?(word)
    end
    false
  end
end
