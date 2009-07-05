require File.dirname(__FILE__) + '/test_helper.rb'

class StorageTest < Test::Unit::TestCase
  
  def teardown
    @temp_file.close if @temp_file
    FileUtils.rm_rf(File.dirname(__FILE__) + '/../tmp')
  end
  
  def temp_file(fixture)
    @temp_file = Tempfile.new('test')
    @temp_file.write(File.new(File.dirname(__FILE__) + "/../test_rails/fixtures/#{fixture}", "r").read)
    return @temp_file
  end
  
  def test_detect_valid_image
    assert HasImage::Processor.valid?(File.dirname(__FILE__) + "/../test_rails/fixtures/image.jpg")
  end

  def test_detect_valid_image_from_tmp_file
    assert HasImage::Processor.valid?(temp_file("image.jpg"))
  end

  def test_detect_invalid_image
    assert !HasImage::Processor.valid?(File.dirname(__FILE__) + "/../test_rails/fixtures/bad_image.jpg")
  end

  def test_detect_invalid_image_from_tmp_file
    assert !HasImage::Processor.valid?(temp_file("bad_image.jpg"))
  end

  def test_resize_with_invalid_geometry
    @processor = HasImage::Processor.new({:convert_to => "JPEG", :output_quality => "85"})
    assert_raises HasImage::InvalidGeometryError do
      @processor.resize(temp_file("image.jpg"), "bad_geometry")
    end
  end
  
  def test_resize_fixed
    @processor = HasImage::Processor.new({:convert_to => "JPEG", :output_quality => "85"})
    assert @processor.resize(temp_file("image.jpg"), "100x100")
  end

  def test_resize_unfixed
    @processor = HasImage::Processor.new({:convert_to => "JPEG", :output_quality => "85"})
    assert @processor.resize(temp_file("image.jpg"), "1024x768>")
  end

  def test_resize_and_convert
    @processor = HasImage::Processor.new({:convert_to => "JPEG", :output_quality => "85"})
    assert @processor.resize(temp_file("image.png"), "100x100")
  end

  def test_resize_should_fail_with_bad_image
    @processor = HasImage::Processor.new({:convert_to => "JPEG", :output_quality => "85"})
    assert_raises HasImage::ProcessorError do
      @processor.resize(temp_file("bad_image.jpg"), "100x100")
    end
  end

end