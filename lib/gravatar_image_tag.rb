module GravatarImageTag

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
     attr_accessor :default_image, :filetype, :rating, :size, :secure
   end

  def self.included(base)
    GravatarImageTag.configure { |c| nil }
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    def gravatar_image_tag(email, options = {})
      options[:alt] ||= 'Gravatar'
      image_tag(GravatarImageTag::gravatar_url(email, options.delete(:gravatar)), options)
    end

  end

  def self.gravatar_url(email, overrides = {})
    overrides ||= {}
    gravatar_params = {
      :default     => GravatarImageTag.configuration.default_image,
      :filetype    => GravatarImageTag.configuration.filetype,
      :rating      => GravatarImageTag.configuration.rating,
      :secure      => GravatarImageTag.configuration.secure,
      :size        => GravatarImageTag.configuration.size
    }.merge(overrides).delete_if { |key, value| value.nil? }
    "#{gravatar_url_base(gravatar_params.delete(:secure))}/#{gravatar_id(email, gravatar_params.delete(:filetype))}#{url_params(gravatar_params)}"
  end

  private

    def self.gravatar_url_base(secure = false)
      'http' + (!!secure ? 's://secure.' : '://') + 'gravatar.com/avatar'
    end

    def self.gravatar_id(email, filetype = nil)
      "#{ Digest::MD5.hexdigest(email) }#{ ".#{filetype}" unless filetype.nil? }" unless email.nil?
    end

    def self.url_params(gravatar_params)
      return nil if gravatar_params.keys.size == 0
      "?#{gravatar_params.map { |key, value| "#{key}=#{URI.escape(value.is_a?(String) ? value : value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"}.join('&amp;')}"
    end

end

ActionView::Base.send(:include, GravatarImageTag) if defined?(ActionView::Base)
