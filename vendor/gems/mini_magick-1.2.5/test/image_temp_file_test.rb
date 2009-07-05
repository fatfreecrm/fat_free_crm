require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/image_temp_file')

class ImageTempFileTest < Test::Unit::TestCase
  include MiniMagick

  def test_multiple_calls_yield_different_files
    first = ImageTempFile.new('test')
    second = ImageTempFile.new('test')
    assert_not_equal first.path, second.path
  end

  def test_temp_file_has_given_extension
    assert_match /^[^.]+\.jpg$/, ImageTempFile.new('jpg').path
    assert_match /^[^.]+\.png$/, ImageTempFile.new('png').path
  end
end
