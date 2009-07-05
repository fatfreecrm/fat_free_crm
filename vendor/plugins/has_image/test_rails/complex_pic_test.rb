require 'test_helper'

class ComplexPic < ActiveRecord::Base
  has_image
end

class ComplexPicTest < Test::Unit::TestCase
  def setup
    # Note: Be sure to not set the whole options hash in your tests below
    ComplexPic.has_image_options = HasImage.default_options_for(ComplexPic)
    ComplexPic.has_image_options[:column] = :filename
    ComplexPic.has_image_options[:base_path] = File.join(RAILS_ROOT, 'tmp')
    ComplexPic.has_image_options[:resize_to] = nil
  end

  def teardown
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'tmp', 'complex_pics'))
  end

  def test_should_save_width_to_db_on_create
    @pic = ComplexPic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert_equal 1916, @pic[:width]
  end

  def test_should_save_height_to_db_on_create
    @pic = ComplexPic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert_equal 1990, @pic[:height]
  end

  def test_should_save_image_size_to_db_on_create
    @pic = ComplexPic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert_equal '1916x1990', @pic[:image_size]
  end

  def test_should_use_value_from_db_in_height_reader
    @pic = ComplexPic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    @pic[:height] = 60_000
    assert_equal 60_000, @pic.height
  end

  def test_should_use_value_from_db_in_width_reader
    @pic = ComplexPic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    @pic[:width] = 60_000
    assert_equal 60_000, @pic.width
  end

end
