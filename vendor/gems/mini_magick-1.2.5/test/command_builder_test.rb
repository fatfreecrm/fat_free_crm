require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/mini_magick')

class CommandBuilderTest < Test::Unit::TestCase
  include MiniMagick

  def test_basic
    c = CommandBuilder.new
    c.resize "30x40"
    assert_equal "-resize 30x40", c.args.join(" ")
  end

  def test_complicated
    c = CommandBuilder.new
    c.resize "30x40"
    c.input 1, 3, 4
    c.lingo "mome fingo"
    assert_equal "-resize 30x40 -input 1 3 4 -lingo mome fingo", c.args.join(" ")
  end
end
