module HasImage

  # Some helpers to make working with HasImage models in views a little
  # easier.
  module ViewHelpers

    # Wraps the image_tag helper from Rails. Instead of passing the path to
    # an image, you can pass any object that uses HasImage. The options can
    # include the name of one of your thumbnails, for example:
    #
    #  image_tag_for(@photo)
    #  image_tag_for(@photo, :thumb => :square)
    #
    # If your object uses fixed dimensions (i.e., "200x200" as opposed to
    # "200x200>"), then the height and width properties will automatically be
    # added to the resulting img tag unless you explicitly specify the size in
    # the options.
    #
    # All arguments other than :thumb will simply be passed along to the Rails
    # image_tag helper without modification.
    #
    # See also: HasImage::ModelInstanceMethods#public_path
    def image_tag_for(object, options = {})
      thumb = options.delete(:thumb)
      if !options[:size]
        if thumb 
          size = object.class.thumbnails[thumb.to_sym]
          options[:size] = size if size =~ /\A[\d]*x[\d]*\Z/
        else
          size = object.class.has_image_options[:resize_to]
          options[:size] = size if size =~ /\A[\d]*x[\d]*\Z/
        end
      end
      image_tag(object.public_path(thumb), options)
    end

  end

end
