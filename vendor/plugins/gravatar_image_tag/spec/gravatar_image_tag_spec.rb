require File.dirname(__FILE__) + '/test_helper'

require 'gravatar_image_tag'

ActionView::Base.send(:include, GravatarImageTag)

describe GravatarImageTag do

  email                 = 'mdeering@mdeering.com'
  md5                   = '4da9ad2bd4a2d1ce3c428e32c423588a'
  default_filetype      = :gif
  default_image         = 'http://mdeering.com/images/default_gravatar.png'
  default_image_escaped = 'http%3A%2F%2Fmdeering.com%2Fimages%2Fdefault_gravatar.png'
  default_rating        = 'x'
  default_size          = 50
  other_image           = 'http://mdeering.com/images/other_gravatar.png'
  other_image_escaped   = 'http%3A%2F%2Fmdeering.com%2Fimages%2Fother_gravatar.png'
  secure                = false

  view = ActionView::Base.new

  {
    { :gravatar_id => md5 } => {},
    { :gravatar_id => md5 } => { :gravatar => { :rating => 'x' } },
    { :gravatar_id => md5, :size => 30 } => { :gravatar => {:size => 30 } },
    { :gravatar_id => md5, :default => other_image_escaped } => { :gravatar => {:default => other_image } },
    { :gravatar_id => md5, :default => other_image_escaped, :size => 30 } => { :gravatar => {:default => other_image, :size => 30 } }
  }.each do |params, options|
    it "#gravatar_image_tag should create the provided url with the provided options #{options}"  do
      view = ActionView::Base.new
      image_tag = view.gravatar_image_tag(email, options)
      image_tag.include?("#{params.delete(:gravatar_id)}").should be_true
      params.all? {|key, value| image_tag.include?("#{key}=#{value}")}.should be_true
    end
  end

  {
    :default_gravatar_image    => default_image,
    :default_gravatar_filetype => default_filetype,
    :default_gravatar_rating   => default_rating,
    :default_gravatar_size     => default_size,
    :secure_gravatar           => secure
  }.each do |singleton_variable, value|
    it "should give a deprication warning for assigning to #{singleton_variable} and passthrough to set the new variable" do
      ActionView::Base.should_receive(:warn)
      ActionView::Base.send("#{singleton_variable}=", value)
      GravatarImageTag.configuration.default_image == value if singleton_variable == :default_gravatar_image
      GravatarImageTag.configuration.filetype      == value if singleton_variable == :default_gravatar_filetype
      GravatarImageTag.configuration.rating        == value if singleton_variable == :default_gravatar_rating
      GravatarImageTag.configuration.size          == value if singleton_variable == :default_gravatar_size
      GravatarImageTag.configuration.secure        == value if singleton_variable == :secure_gravatar
    end
  end

  # Now that the defaults are set...
  {
    { :gravatar_id => md5, :size => default_size, :default => default_image_escaped } => {},
    { :gravatar_id => md5, :size => 30, :default => default_image_escaped } => { :gravatar => { :size => 30 } },
    { :gravatar_id => md5, :size => default_size, :default => other_image_escaped } => { :gravatar => {:default => other_image } },
    { :gravatar_id => md5, :size => 30, :default => other_image_escaped } => { :gravatar => { :default => other_image, :size => 30 } },
  }.each do |params, options|
    it "#gravatar_image_tag #{params} should create the provided url when defaults have been set with the provided options #{options}"  do
      view = ActionView::Base.new
      image_tag = view.gravatar_image_tag(email, options)
      image_tag.include?("#{params.delete(:gravatar_id)}.#{default_filetype}").should be_true
      params.all? {|key, value| image_tag.include?("#{key}=#{value}")}.should be_true
    end
  end

  it 'should request the gravatar image from the non-secure server if the https => false option is given' do
    (!!view.gravatar_image_tag(email, { :gravatar => { :secure => false } }).match(/^https:\/\/secure.gravatar.com\/avatar\//)).should be_false
  end

  it 'should request the gravatar image from the secure server if the https => true option is given' do
    (!!view.gravatar_image_tag(email, { :gravatar => { :secure => true } }).match(/src="https:\/\/secure.gravatar.com\/avatar\//)).should be_true
  end

  it 'GravatarImageTag#gravitar_id should not error out when email is nil' do
    lambda { GravatarImageTag::gravatar_id(nil) }.should_not  raise_error(TypeError)
  end

end
