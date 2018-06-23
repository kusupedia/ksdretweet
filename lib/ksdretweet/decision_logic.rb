require 'natto'
class DecisionLogic
    def include_word? (text)
       rp1 = Regexp.new("^RT*")
       return false if rp1 =~ text
       return false if text.include?("ksdretweet")
       if text.include?("あいな") then
           return false if text.include?("あいなぷぅ")
           if text.include?("相羽") then
             return true if text.include?("楠田")
             return false
           end
           if text.include?("鈴木") then
             return true if text.include?("楠田")
             return false
           end
           if text.include?("あいななごはん") then
             return true if text.include?("楠田")
             return false
           end
           nm = Natto::MeCab.new
           nm.parse(text) do |n|
              return true if n.surface == "あいな"
           end
       end
       includeWordList = ["楠田","亜衣奈","くっすん","くすリル","kusudaaina"]
       includeWordList.each do|word|
           return true if text.include?(word)
       end
       return false
    end
end
