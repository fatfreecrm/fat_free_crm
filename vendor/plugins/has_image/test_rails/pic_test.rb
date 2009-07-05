require 'test_helper'

class Pic < ActiveRecord::Base
  has_image
end

class PicWithDifferentTableName < ActiveRecord::Base
  set_table_name 'pics'
end

class PicTest < Test::Unit::TestCase
  def setup
    # Note: Be sure to not set the whole options hash in your tests below
    Pic.has_image_options = HasImage.default_options_for(Pic)
    Pic.has_image_options[:base_path] = File.join(RAILS_ROOT, 'tmp')
  end

  def teardown
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'tmp', 'pics'))
  end

  def test_should_be_valid
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert @pic.valid? , "#{@pic.errors.full_messages.to_sentence}"
  end

  def test_should_be_too_big
    Pic.has_image_options[:max_size] = 1.kilobyte
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert !@pic.valid?
  end

  def test_should_be_too_small
    Pic.has_image_options[:min_size] = 1.gigabyte
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert !@pic.valid?
  end

  def test_invalid_image_detected
    @pic = Pic.new(:image_data => fixture_file_upload("/bad_image.jpg", "image/jpeg"))
    assert !@pic.valid?
  end

  def test_create
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert @pic.save!
    assert_not_nil @pic.public_path
    assert_not_nil @pic.absolute_path
  end

  def test_update
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    @pic.save!
    @pic.image_data = fixture_file_upload("/image.png", "image/png")
    assert @pic.save!
  end

  def test_finding_from_url_path
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    @pic.save!
    path = HasImage::Storage.partitioned_path @pic.id
    assert_equal @pic, Pic.from_partitioned_path(path)
  end

  def test_default_options_respect_table_name
    assert_equal 'pics', HasImage.default_options_for(PicWithDifferentTableName)[:path_prefix]
  end

  def test_generate_thumbnails_on_create
    Pic.has_image_options[:thumbnails] = {:tiny => "16x16"}
    @pic = Pic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert File.exist?(@pic.absolute_path(:tiny))
  end

  def test_doesnt_generate_thumbnails_if_option_disabled
    Pic.has_image_options[:thumbnails] = {:tiny => "16x16"}
    Pic.has_image_options[:auto_generate_thumbnails] = false
    @pic = Pic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert !File.exist?(@pic.absolute_path(:tiny))
  end

  def test_regenerate_thumbnails_succeeds
    Pic.has_image_options[:thumbnails] = {:small => "100x100", :tiny => "16x16"}
    
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    @pic.save!
    assert @pic.regenerate_thumbnails
  end

  def test_create_model_without_setting_image_data
    assert Pic.new.save!
  end

  def test_destroy_model_without_no_images
    @pic = Pic.new
    @pic.save!
    assert @pic.destroy
  end

  def test_destroy_should_not_remove_image_file_if_option_is_set
    Pic.has_image_options[:delete] = false
    @pic = Pic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    @pic.destroy
    assert File.exist?(@pic.absolute_path)
  end

  def test_destroy_model_with_images_already_deleted_from_filesystem
    @pic = Pic.new
    @pic.save!
    @pic.update_attribute(:has_image_file, "test")
    assert @pic.destroy
  end

  def test_create_with_png
    Pic.has_image_options[:min_size] = 1
    @pic = Pic.new(:image_data => fixture_file_upload("/image.png", "image/png"))
    assert @pic.save!
  end

  def test_multiple_calls_to_valid_doesnt_blow_away_temp_image
    Pic.has_image_options[:min_size] = 1
    @pic = Pic.new(:image_data => fixture_file_upload("/image.png", "image/png"))
    @pic.valid?
    assert @pic.valid?
  end

  def test_dimension_getters
    Pic.has_image_options[:resize_to] = "100x200"
    pic = Pic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert_equal 100, pic.width
    assert_equal 200, pic.height
    assert_equal '100x200', pic.image_size
  end

  def test_image_isnt_resized_when_resize_to_set_to_nil
    Pic.has_image_options[:resize_to] = nil
    pic = Pic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))

    assert_equal 1916, pic.width
    assert_equal 1990, pic.height
  end

  def test_image_isnt_resized_but_converted_when_resize_to_set_to_nil
    Pic.has_image_options[:resize_to] = nil
    Pic.has_image_options[:convert_to] = 'PNG'
    pic = Pic.create!(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))

    assert_equal 'PNG', MiniMagick::Image.from_file(pic.absolute_path)[:format]
    assert_equal 1916, pic.width
    assert_equal 1990, pic.height
  end

end
