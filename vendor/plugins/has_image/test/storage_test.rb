require 'test_helper.rb'

class StorageTest < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
    FileUtils.rm_rf(File.dirname(__FILE__) + '/../tmp')
    @temp_file.close! if @temp_file && !@temp_file.closed?
  end
  
  def default_options
    mock_class = "test"
    mock_class.stubs(:table_name).returns('tests')
    HasImage.default_options_for(mock_class).merge(
      :base_path => File.join(File.dirname(__FILE__), '..', 'tmp')
    )
  end
  
  def test_partitioned_path
    assert_equal(["0001", "2345"], HasImage::Storage.partitioned_path("12345"))
  end
  
  def test_partitioned_path_doesnt_collide_with_high_ids
    assert_not_equal HasImage::Storage.partitioned_path(867792732),
      HasImage::Storage.partitioned_path(867792731)
    # FIXME: collisions when IDs have more than 8 digits
    # assert_not_equal HasImage::Storage.partitioned_path(967792731),
    #   HasImage::Storage.partitioned_path(967792731)  
  end
  
  def test_id_from_partitioned_path
    assert_equal 123, HasImage::Storage.id_from_partitioned_path(HasImage::Storage.partitioned_path(123))
    assert_equal 56, HasImage::Storage.id_from_partitioned_path(HasImage::Storage.partitioned_path(56))
    assert_equal 67792732, HasImage::Storage.id_from_partitioned_path(HasImage::Storage.partitioned_path(67792732))
    # FIXME: for IDs with more than 8 digits partitioned path is destructive
    # assert_equal 867792731, HasImage::Storage.id_from_partitioned_path(HasImage::Storage.partitioned_path(867792731))
  end
  
  def test_id_from_path_accepts_array
    assert_equal 123, HasImage::Storage.id_from_path(['0000','0123','image_something.jpg'])
  end
  
  def test_id_from_path_accepts_path
    assert_equal 12345, HasImage::Storage.id_from_path('0001/2345/0123/image_something.jpg')
  end
  
  def test_generated_file_name
    assert_equal("1", HasImage::Storage.generated_file_name(stub(:to_param => 1)))
  end
  
  def test_path_for
    @storage = HasImage::Storage.new(default_options)
    assert_match(/\/tmp\/tests\/0000\/0001/, @storage.send(:path_for, 1))
  end
  
  def test_public_path_for
    @storage = HasImage::Storage.new(default_options.merge(:base_path => '/public'))
    pic = stub(:has_image_file => "mypic", :has_image_id => 1)
    assert_equal "/tests/0000/0001/mypic_square.jpg", @storage.public_path_for(pic, :square)
  end
  
  def test_public_path_for_image_with_html_special_symbols_in_name
    @storage = HasImage::Storage.new(default_options.merge(:base_path => '/public'))
    pic = stub(:has_image_file => "my+pic", :has_image_id => 1)
    assert_equal "/tests/0000/0001/my%2Bpic_square.jpg", @storage.public_path_for(pic, :square)
  end
  
  def test_name_generation_takes_into_account_thumbnail_separator_constant
    old_separator = HasImage::Storage.thumbnail_separator
    
    @storage = HasImage::Storage.new(default_options.merge(:thumbnails => {:schick => '22x22'}, :base_path => '/public'))
    HasImage::Storage.thumbnail_separator = '.'
    pic = stub(:has_image_file => "pic", :has_image_id => 1)
    assert_equal "/tests/0000/0001/pic.schick.jpg", @storage.public_path_for(pic, :schick)
    
    HasImage::Storage.thumbnail_separator = old_separator
  end

  def test_escape_file_name_for_http
    @storage = HasImage::Storage.new(default_options.merge(:base_path => '/public'))
    real = @storage.escape_file_name_for_http("/tests/0000/0001/mypic+square?something.jpg")
    assert_equal "/tests/0000/0001/mypic%2Bsquare%3Fsomething.jpg", real
  end

  def test_escape_file_name_for_http_escapes_only_filename
    @storage = HasImage::Storage.new(default_options.merge(:base_path => '/public'))
    real = @storage.escape_file_name_for_http("/tests/00+00/0001/mypic+square?something.jpg")
    assert_equal "/tests/00+00/0001/mypic%2Bsquare%3Fsomething.jpg", real
  end
  
  def test_filename_for
    @storage = HasImage::Storage.new(default_options)
    assert_equal "test.jpg", @storage.send(:file_name_for, "test")
  end

  def test_set_data_from_file
    @storage = HasImage::Storage.new(default_options)
    @file = File.new(File.dirname(__FILE__) + "/../test_rails/fixtures/image.jpg", "r")
    @storage.image_data = @file
    assert @storage.temp_file.size > 0
    assert_equal Zlib.crc32(@file.read), Zlib.crc32(@storage.temp_file.read)
  end
  
  def test_set_data_from_tempfile
    @storage = HasImage::Storage.new(default_options)
    @storage.image_data = temp_file("image.jpg")
    assert @storage.temp_file.size > 0
    assert_equal Zlib.crc32(@storage.temp_file.read), Zlib.crc32(@temp_file.read)
  end
  
  def test_install_and_remove_images
    @storage = HasImage::Storage.new(default_options.merge(:thumbnails => {
      :one => "100x100", :two => "200x200"}))
    @storage.image_data = temp_file("image.jpg")
    @name = @storage.install_images(stub(:has_image_id => 1))
    assert @storage.remove_images(stub(:has_image_id => 1), @name)
  end
  
  def test_install_images_doesnt_automatically_generate_thumbnails_if_that_option_is_set
    @storage = HasImage::Storage.new(default_options.merge(
      :thumbnails => {:two => "200x200"},
      :auto_generate_thumbnails => false
    ))
    @storage.image_data = temp_file("image.jpg")
    @storage.expects(:generate_thumbnails).never
    @storage.install_images(stub(:has_image_id => 1))
  end

  def test_image_not_too_small
    @storage = HasImage::Storage.new(default_options.merge(:min_size => 1.kilobyte))
    @storage.image_data = temp_file("image.jpg")
    assert !@storage.image_too_small?
  end
  
  def test_image_too_small
    @storage = HasImage::Storage.new(default_options.merge(:min_size => 1.gigabyte))
    @storage.image_data = temp_file("image.jpg")
    assert @storage.image_too_small?
  end
  
  def test_image_too_big
    @storage = HasImage::Storage.new(default_options.merge(:max_size => 1.kilobyte))
    @storage.image_data = temp_file("image.jpg")    
    assert @storage.image_too_big?
  end

  def test_image_not_too_big
    @storage = HasImage::Storage.new(default_options.merge(:max_size => 1.gigabyte))
    @storage.image_data = temp_file("image.jpg")    
    assert !@storage.image_too_big?
  end
  
  private
  
  def temp_file(fixture)
    file = File.new(File.dirname(__FILE__) + "/../test_rails/fixtures/#{fixture}", "r")
    @temp_file = Tempfile.new("test")
    @temp_file.write(file.read)
    return @temp_file
  end
  
end