require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/mini_magick')

class ImageTest < Test::Unit::TestCase
  include MiniMagick

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__)) + "/"

  SIMPLE_IMAGE_PATH = CURRENT_DIR + "simple.gif"
  TIFF_IMAGE_PATH = CURRENT_DIR + "leaves.tiff"
  NOT_AN_IMAGE_PATH = CURRENT_DIR + "not_an_image.php"
  GIF_WITH_JPG_EXT = CURRENT_DIR + "actually_a_gif.jpg"
  EXIF_IMAGE_PATH = CURRENT_DIR + "trogdor.jpg"
  ANIMATION_PATH = CURRENT_DIR + "animation.gif"

  def test_image_from_blob
    File.open(SIMPLE_IMAGE_PATH, "rb") do |f|
      image = Image.from_blob(f.read)
    end
  end

  def test_image_from_file
    image = Image.from_file(SIMPLE_IMAGE_PATH)
  end

  def test_image_new
    image = Image.new(SIMPLE_IMAGE_PATH)
  end

  def test_image_write
    output_path = "output.gif"
    begin
      image = Image.new(SIMPLE_IMAGE_PATH)
      image.write output_path

      assert File.exists?(output_path)
    ensure
      File.delete output_path
    end
  end

  def test_not_an_image
    assert_raise(MiniMagickError) do
      image = Image.new(NOT_AN_IMAGE_PATH)
    end
  end

  def test_image_meta_info
    image = Image.new(SIMPLE_IMAGE_PATH)
    assert_equal 150, image[:width]
    assert_equal 55, image[:height]
    assert_equal [150, 55], image[:dimensions]
    assert_match(/^gif$/i, image[:format])
  end

  def test_tiff
    image = Image.new(TIFF_IMAGE_PATH)
    assert_equal "tiff", image[:format].downcase
    assert_equal 295, image[:width]
    assert_equal 242, image[:height]
  end

  def test_animation_pages
    image = Image.from_file(ANIMATION_PATH)
    image.format "png", 0
    assert_equal "png", image[:format].downcase
  end

  def test_animation_size
    image = Image.from_file(ANIMATION_PATH)
    assert_equal image[:size], 76631
  end

  def test_gif_with_jpg_format
    image = Image.new(GIF_WITH_JPG_EXT)
    assert_equal "gif", image[:format].downcase
  end

  def test_image_resize
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    image.resize "20x30!"

    assert_equal 20, image[:width]
    assert_equal 30, image[:height]
    assert_match(/^gif$/i, image[:format])
  end

  def test_image_resize_with_minimum
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    original_width, original_height = image[:width], image[:height]
    image.resize "#{original_width + 10}x#{original_height + 10}>"

    assert_equal original_width, image[:width]
    assert_equal original_height, image[:height]
  end

  def test_image_combine_options_resize_blur
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    image.combine_options do |c|
      c.resize "20x30!"
      c.blur 50
    end

    assert_equal 20, image[:width]
    assert_equal 30, image[:height]
    assert_match(/^gif$/i, image[:format])
  end

  def test_exif
    image = Image.from_file(EXIF_IMAGE_PATH)
    assert_equal('0220', image["exif:ExifVersion"])
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    assert_equal('', image["EXIF:ExifVersion"])
  end

  def test_original_at
    image = Image.from_file(EXIF_IMAGE_PATH)
    assert_equal(Time.local('2005', '2', '23', '23', '17', '24'), image[:original_at])
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    assert_nil(image[:original_at])
  end

  def test_tempfile_at_path
    image = Image.from_file(TIFF_IMAGE_PATH)
    assert_equal image.path, image.tempfile.path
  end

  def test_tempfile_at_path_after_format
    image = Image.from_file(TIFF_IMAGE_PATH)
    image.format('png')
    assert_equal image.path, image.tempfile.path
  end

  def test_previous_tempfile_deleted_after_format
    image = Image.from_file(TIFF_IMAGE_PATH)
    before = image.path.dup
    image.format('png')
    assert !File.exist?(before)
  end

  def test_mini_magick_error_when_referencing_not_existing_page
    image = Image.from_file(ANIMATION_PATH)
    assert_raises MiniMagickError do
      image.format('png', 31415)
    end
  end
end
