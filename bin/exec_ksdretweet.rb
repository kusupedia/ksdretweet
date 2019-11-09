# frozen_string_literal: true

$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')

require 'ksdretweet'

ksdretweet = Ksdretweet.new
ksdretweet.run
