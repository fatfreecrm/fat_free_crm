require 'has_image/processor'
require 'has_image/storage'
require 'has_image/view_helpers'

# = HasImage
#
# HasImage allows you to very easily attach images to a Rails model. For some
# more basic info on what it does, please see its {project
# page}[http://github.com/norman/has_image] on GitHub.
#
# Install HasImage by using Ruby Gems:
#
#  sudo gem install has_image
#
# To use HasImage in your project, you must add a varchar column to your
# model. By default, this column should be named "has_image_file," though you
# may easily change this. For option defaults, see
# HasImage#default_options_for and ClassMethods#has_image.
#
# == Basic Examples
##
# Uses all default options. This works, but is likely not what you need.
#
#  class Photo < ActiveRecord::Base
#    has_image
#  end
#
# Resize the uploaded image to 800x800 and create a 150x150 thumbnail.
#
#   has_image :resize_to "800x800", :thumbnails => {:square => "150x150"}
#
# Resize the image and set a max file size to 4 megabytes.
#
#   has_image :resize_to "100x150", :max_size => 4.megabytes
#
# == Some slightly more advanced examples
#
# === Localizing HasImage
#
#  has_image :invalid_image_message => "No se puede procesar la imagen."
#
# === Using has_image with Capistrano
#
# When deploying using Capistrano, you will likely want to keep images
# under a "system" directory so that newly deployed versions have access
# to them:
#
#   has_image :resize_to => "150x150",
#     :thumbnails => {
#       :square => "75x75",
#     },
#     :base_path => File.join(Rails.root, 'public', 'system')
#
# === Testing with HasImage:
#
# If you want your tests to actually run the image processing, you should
# make sure your tests write the image files somewhere outside your public
# directory. Add something like this to your config/environments/test.rb:
#
#   config.after_initialize do
#     MyClass.has_image_options[:base_path] = File.join(RAILS_ROOT, "tmp")
#   end
#
# If you want to stub out calls to has_image so that your tests don't do
# the (slow) image processing, here's an example using Test::Unit and
# Mocha:
#
#   def setup
#     Photo.any_instance.stubs(:image_data=).returns(true)
#     Photo.any_instance.stubs(:install_images).returns(true)
#     Photo.any_instance.stubs(:image_data_valid?).returns(true)
#   end
#
module HasImage

  class ProcessorError < StandardError ; end
  class StorageError < StandardError ; end
  class FileTooBigError < StorageError ; end
  class FileTooSmallError < StorageError ; end
  class InvalidGeometryError < ProcessorError ; end

  class << self

    def included(base) # :nodoc:
      base.extend(ClassMethods)
    end

    # Enables has_image functionality. You probably don't need to ever invoke
    # this.
    def enable # :nodoc:
      return if ActiveRecord::Base.respond_to? :has_image
      ActiveRecord::Base.send(:include, HasImage)
      return if ActionView::Base.respond_to? :image_tag_for
      ActionView::Base.send(:include, ViewHelpers)
    end

    # If you're invoking this method, you need to pass in the class for which
    # you want to get default options; this is used to determine the path where
    # the images will be stored in the file system. Take a look at
    # HasImage::ClassMethods#has_image to see examples of how to set the options
    # in your model.
    #
    # This method is called by your model when you call has_image. It's
    # placed here rather than in the model's class methods to make it easier
    # to access for testing. Unless you're working on the code, it's unlikely
    # you'll ever need to invoke this method.
    #
    # * :resize_to => "200x200",
    # * :thumbnails => {},
    # * :auto_generate_thumbnails => true,
    # * :delete => true,
    # * :max_size => 12.megabytes,
    # * :min_size => 4.kilobytes,
    # * :path_prefix => klass.table_name,
    # * :base_path => File.join(RAILS_ROOT, 'public'),
    # * :column => :has_image_file,
    # * :convert_to => "JPEG",
    # * :output_quality => "85",
    # * :invalid_image_message => "Can't process the image.",
    # * :image_too_small_message => "The image is too small.",
    # * :image_too_big_message => "The image is too big."
    def default_options_for(klass)
      {
        :resize_to => "200x200",
        :thumbnails => {},
        :auto_generate_thumbnails => true,
        :delete => true,
        :max_size => 12.megabytes,
        :min_size => 4.kilobytes,
        :path_prefix => klass.table_name,
        :base_path => File.join(RAILS_ROOT, 'public'),
        :column => :has_image_file,
        :convert_to => "JPEG",
        :output_quality => "85",
        :invalid_image_message => "Can't process the image.",
        :image_too_small_message => "The image is too small.",
        :image_too_big_message => "The image is too big."
      }
    end

  end

  module ClassMethods

    # === Options
    #
    # *  <tt>:resize_to</tt> - Dimensions to resize to. This should be an ImageMagick {geometry string}[http://www.imagemagick.org/script/command-line-options.php#resize]. Fixed sizes are recommended.
    # *  <tt>:thumbnails</tt> - A hash of thumbnail names and dimensions. The dimensions should be ImageMagick {geometry strings}[http://www.imagemagick.org/script/command-line-options.php#resize]. Fixed sized are recommended.
    # *  <tt>:auto_generate_thumbnails</tt> - Flag to indicate whether to automatically generate thumbnails when the image_data changes (e.g. on create). If you set this to false, your application code needs to take care of generating thumbnails, e.g. using +#generate_thumbnail+
    # *  <tt>:delete</tt> - Flag to indicate if the images should be deleted from the storage (e.g. the filesystem) when the record is destroyed.
    # *  <tt>:min_size</tt> - Minimum file size allowed. It's recommended that you set this size in kilobytes.
    # *  <tt>:max_size</tt> - Maximum file size allowed. It's recommended that you set this size in megabytes.
    # *  <tt>:base_path</tt> - Where to install the images.
    # *  <tt>:path_prefix</tt> - Where to install the images, relative to basepath.
    # *  <tt>:convert_to</tt> - An ImageMagick format to convert images to.
    # *  <tt>:output_quality</tt> - Image output quality passed to ImageMagick.
    # *  <tt>:invalid_image_message</tt> - The message that will be shown when the image data can't be processed.
    # *  <tt>:image_too_small_message</tt> - The message that will be shown when the image file is too small. You should ideally set this to something that tells the user what the minimum is.
    # *  <tt>:image_too_big_message</tt> - The message that will be shown when the image file is too big. You should ideally set this to something that tells the user what the maximum is.
    def has_image(options = {})
      options.assert_valid_keys(HasImage.default_options_for(self).keys)
      options = HasImage.default_options_for(self).merge(options)
      class_inheritable_accessor :has_image_options
      write_inheritable_attribute(:has_image_options, options)

      after_create :install_images
      after_save :update_images
      after_destroy :remove_images

      validate_on_create :image_data_valid?

      include ModelInstanceMethods
      extend  ModelClassMethods

    end

  end

  module ModelInstanceMethods

    # Does the object have an image?
    def has_image?
      !send(has_image_options[:column]).blank?
    end

    # Sets the uploaded image data. Image data can be an instance of Tempfile,
    # or an instance of any class than inherits from IO.
    # aliased as uploaded_data= for compatibility with attachment_fu
    def image_data=(image_data)
      return if image_data.blank?
      storage.image_data = image_data
    end
    alias_method :uploaded_data=, :image_data=
    # nil placeholder in case this field is used in a form.
    # Aliased as uploaded_data for compatibility with attachment_fu
    def image_data
      nil
    end
    alias_method :uploaded_data, :image_data

    # Is the image data a file that ImageMagick can process, and is it within
    # the allowed minimum and maximum sizes?
    def image_data_valid?
      return if !storage.temp_file
      if storage.image_too_big?
        errors.add_to_base(self.class.has_image_options[:image_too_big_message])
      elsif storage.image_too_small?
        errors.add_to_base(self.class.has_image_options[:image_too_small_message])
      elsif !HasImage::Processor.valid?(storage.temp_file)
        errors.add_to_base(self.class.has_image_options[:invalid_image_message])
      end
    end

    # Gets the "web path" for the image, or optionally, its thumbnail.
    # Aliased as +public_filename+ for compatibility with attachment-Fu
    def public_path(thumbnail = nil)
      storage.public_path_for(self, thumbnail)
    end
    alias_method :public_filename, :public_path

    # Gets the absolute filesystem path for the image, or optionally, its
    # thumbnail.
    def absolute_path(thumbnail = nil)
      storage.filesystem_path_for(self, thumbnail)
    end

    # Regenerates the thumbails from the main image.
    def regenerate_thumbnails!
      storage.generate_thumbnails(has_image_id, send(has_image_options[:column]))
    end
    alias_method :regenerate_thumbnails, :regenerate_thumbnails! #Backwards compat

    def generate_thumbnail!(thumb_name)
      storage.generate_thumbnail(has_image_id, send(has_image_options[:column]), thumb_name)
    end

    def width
      self[:width] || storage.measure(absolute_path, :width)
    end

    def height
      self[:height] || storage.measure(absolute_path, :height)
    end

    def image_size
      self[:image_size] || [width, height].join('x')
    end

    # Deletes the image from the storage.
    def remove_images
      return if send(has_image_options[:column]).blank? || !has_image_options[:delete]
      self.class.transaction do
        begin
          storage.remove_images(self, send(has_image_options[:column]))
          # The record will be frozen if we're being called after destroy.
          unless frozen?
            # FIXME: although this is cleaner now, it introduces a new issue
            # with partial updates.
            updates    = "#{connection.quote_column_name(has_image_options[:column])} = NULL"
            conditions = "#{connection.quote_column_name(self.class.primary_key)} = #{connection.quote(id)}"
            self.class.update_all(updates, conditions)
            self.send("#{has_image_options[:column]}=", nil)
          end
        rescue Errno::ENOENT
          logger.warn("Could not delete files for #{self.class.to_s} #{to_param}")
        end
      end
    end

    # Creates new images and removes the old ones when image_data has been
    # set.
    def update_images
      return if storage.temp_file.blank?
      remove_images
      populate_attributes
    end

    # Processes and installs the image and its thumbnails.
    def install_images
      return if !storage.temp_file
      populate_attributes
    end

    # Gets an instance of the underlying storage functionality. See
    # HasImage::Storage.
    def storage
      @storage ||= HasImage::Storage.new(has_image_options)
    end

    # By default, just returns the model's id. Since this id is used to divide
    # the images up in directories, you can override this to return a related
    # model's id if you want the images to be grouped differently. For example,
    # if a "member" has_many "photos" you can override this to return
    # member.id to group images by member.
    def has_image_id
      id
    end

    private

    def populate_attributes
      # FIXME: this is a quick and dirty work around for image updates
      # breaking when running with Rails' partial updates. This is originated
      # by the update_all call in the remove_images method which bypasses
      # ActiveRecord::Dirty attribute change tracking.
      attribute_will_change!(has_image_options[:column].to_s) if respond_to?(:attribute_will_change!, true)

      send("#{has_image_options[:column]}=", storage.install_images(self))
      self[:width] = storage.measure(absolute_path, :width) if self.class.column_names.include?('width')
      self[:height] = storage.measure(absolute_path, :height) if self.class.column_names.include?('height')
      self[:image_size] = [storage.measure(absolute_path, :width), storage.measure(absolute_path, :height)].join('x') if self.class.column_names.include?('image_size')
      save!
    end

  end

  module ModelClassMethods

    # Get the hash of thumbnails set by the options specified when invoking
    # HasImage::ClassMethods#has_image.
    def thumbnails
      has_image_options[:thumbnails]
    end

    def from_partitioned_path(path)
      find HasImage::Storage.id_from_path(path)
    end

  end

end

if defined?(Rails) and defined?(ActiveRecord) and defined?(ActionController)
  HasImage.enable
end
