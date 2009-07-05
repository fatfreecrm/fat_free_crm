require 'active_support'
require 'stringio'
require 'fileutils'
require 'zlib'

module HasImage  
  
  # Filesystem storage for the HasImage gem. The methods that HasImage inserts
  # into ActiveRecord models only depend on the public methods in this class,
  # so it should be reasonably straightforward to implement a different
  # storage mechanism for Amazon AWS, Photobucket, DBFile, SFTP, or whatever
  # you want.  
  class Storage
    class_inheritable_accessor :thumbnail_separator
    write_inheritable_attribute :thumbnail_separator, '_'
    
    attr_accessor :image_data, :options, :temp_file

    class << self
      
      # {Jamis Buck's well known
      # solution}[http://www.37signals.com/svn/archives2/id_partitioning.php]
      # to this problem fails with high ids, such as those created by
      # db:fixture:load. This version scales to large ids more gracefully.
      # Thanks to Adrian Mugnolo for the fix.
      #++
      # FIXME: collides with IDs with more than 8 digits
      #--
      def partitioned_path(id, *args)
        ["%04d" % ((id.to_i / 1e4) % 1e4), "%04d" % (id.to_i % 1e4)].concat(args)
      end
      
      def id_from_partitioned_path(partitioned_path)
        partitioned_path.join.to_i
      end
      
      def id_from_path(path)
        path = path.split('/') if path.is_a?(String)
        path_partitions = 2
        id_from_partitioned_path(path.first(path_partitions))
      end
      
      # By default, simply accepts and returns the id of the object. This is
      # here to allow you to monkey patch this method, for example, if you
      # wish instead to generate and return a UUID.
      def generated_file_name(*args)
        return args.first.to_param.to_s
      end
    end

    # The constuctor should be invoked with the options set by has_image.
    def initialize(options) # :nodoc:
      @options = options
    end

    # The image data can be anything that inherits from IO. If you pass in an
    # instance of Tempfile, it will be used directly without being copied to
    # a new temp file.
    def image_data=(image_data)
      raise StorageError.new if image_data.blank?
      if image_data.is_a?(Tempfile)
        @temp_file = image_data
      else
        image_data.rewind
        @temp_file = Tempfile.new 'has_image_data_%s' % Storage.generated_file_name
        @temp_file.write(image_data.read)
      end
    end

    # Is uploaded file smaller than the allowed minimum?
    def image_too_small?
      @temp_file.open if @temp_file.closed?
      @temp_file.size < options[:min_size]
    end
    
    # Is uploaded file larger than the allowed maximum?
    def image_too_big?
      @temp_file.open if @temp_file.closed?
      @temp_file.size > options[:max_size]
    end
    
    # Invokes the processor to resize the image(s) and the installs them to
    # the appropriate directory.
    def install_images(object)
      generated_name = Storage.generated_file_name(object)
      install_main_image(object.has_image_id, generated_name)
      generate_thumbnails(object.has_image_id, generated_name) if thumbnails_needed?
      return generated_name
    ensure  
      @temp_file.close! if !@temp_file.closed?
      @temp_file = nil
    end
    
    # Measures the given dimension using the processor
    def measure(path, dimension)
      processor.measure(path, dimension)
    end
    
    # Gets the "web" path for an image. For example:
    #
    #   /photos/0000/0001/3er0zs.jpg
    def public_path_for(object, thumbnail = nil)
      webpath = filesystem_path_for(object, thumbnail).gsub(/\A.*public/, '')
      escape_file_name_for_http(webpath)
    end
    
    def escape_file_name_for_http(webpath)
      dir, file = File.split(webpath)
      File.join(dir, CGI.escape(file))
    end
    
    # Deletes the images and directory that contains them.
    def remove_images(object, name)
      FileUtils.rm Dir.glob(File.join(path_for(object.has_image_id), name + '*'))
      Dir.rmdir path_for(object.has_image_id)
    rescue SystemCallError 
    end

    # Is the uploaded file within the min and max allowed sizes?
    def valid?
      !(image_too_small? || image_too_big?)
    end
    
    # Write the thumbnails to the install directory - probably somewhere under
    # RAILS_ROOT/public.
    def generate_thumbnails(id, name)
      ensure_directory_exists!(id)
      options[:thumbnails].keys.each { |thumb_name| generate_thumbnail(id, name, thumb_name) }
    end
    alias_method :regenerate_thumbnails, :generate_thumbnails #Backwards-compat
    
    def generate_thumbnail(id, name, thumb_name)
      size_spec = options[:thumbnails][thumb_name.to_sym]
      raise StorageError unless size_spec
      ensure_directory_exists!(id)
      File.open absolute_path(id, name, thumb_name), "w" do |thumbnail_destination|
        processor.process absolute_path(id, name), size_spec do |thumbnail_data|
          thumbnail_destination.write thumbnail_data
        end
      end
    end
     
    # Gets the full local filesystem path for an image. For example:
    #
    #   /var/sites/example.com/production/public/photos/0000/0001/3er0zs.jpg
    def filesystem_path_for(object, thumbnail = nil)
      File.join(path_for(object.has_image_id), file_name_for(object.send(options[:column]), thumbnail))
    end
    
    protected

    # Gets the extension to append to the image. Transforms "jpeg" to "jpg."
    def extension
      options[:convert_to].to_s.downcase.gsub("jpeg", "jpg")
    end
    
    private
    
    # File name, plus thumbnail suffix, plus extension. For example:
    #
    #   file_name_for("abc123", :thumb)
    #
    # gives you:
    #
    #   "abc123_thumb.jpg"
    #   
    # It uses an underscore to separatore parts by default, but that is configurable
    # by setting HasImage::Storage.thumbnail_separator
    def file_name_for(*args)
      "%s.%s" % [args.compact.join(self.class.thumbnail_separator), extension]
    end

    # Get the full path for the id. For example:
    #
    #  /var/sites/example.org/production/public/photos/0000/0001
    def path_for(id)
      debugger if $debug
      File.join(options[:base_path], options[:path_prefix], Storage.partitioned_path(id))
    end
    
    def absolute_path(id, *args)
      File.join(path_for(id), file_name_for(*args))
    end
    
    def ensure_directory_exists!(id)
      FileUtils.mkdir_p path_for(id)
    end
    
    # Write the main image to the install directory - probably somewhere under
    # RAILS_ROOT/public.
    def install_main_image(id, name)
      ensure_directory_exists!(id)
      File.open absolute_path(id, name), "w" do |final_destination|
        processor.process(@temp_file) do |processed_image|
          final_destination.write processed_image
        end
      end
    end
    
    # used in #install_images
    def thumbnails_needed?
      !options[:thumbnails].empty? && options[:auto_generate_thumbnails]
    end
    
    # Instantiates the processor using the options set in my contructor (if
    # not already instantiated), stores it in an instance variable, and
    # returns it.
    def processor
      @processor ||= Processor.new(options)
    end
  end
  
end