# frozen_string_literal: true

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
    attr_accessor :default_image, :filetype, :rating, :size
   end

  def self.included(base)
    GravatarImageTag.configure { |_c| nil }
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def gravatar_image_tag(email, options = {})
      raise ArgumentError, "Options must be a hash, got #{options.inspect}" unless options.is_a? Hash

      options[:alt] ||= 'Gravatar'
      image_tag(GravatarImageTag.gravatar_url(email, options.delete(:gravatar)), options)
    end
  end

  def self.gravatar_url(email, overrides = {})
    overrides ||= {}
    gravatar_params = {
      default:     GravatarImageTag.configuration.default_image,
      filetype:    GravatarImageTag.configuration.filetype,
      rating:      GravatarImageTag.configuration.rating,
      size:        GravatarImageTag.configuration.size
    }.merge(overrides).delete_if { |_key, value| value.nil? }
    "#{gravatar_url_base}/#{gravatar_id(email, gravatar_params.delete(:filetype))}#{url_params(gravatar_params)}"
  end

  def self.gravatar_url_base
    'https://gravatar.com/avatar'
  end

  def self.gravatar_id(email, filetype = nil)
    "#{Digest::MD5.hexdigest(email)}#{".#{filetype}" unless filetype.nil?}" unless email.nil?
  end

  def self.url_params(gravatar_params)
    return nil if gravatar_params.keys.empty?

    "?#{gravatar_params.map { |key, value| "#{key}=#{CGI.escape(value.is_a?(String) ? value : value.to_s)}" }.join('&amp;')}"
  end
end

ActionView::Base.include GravatarImageTag if defined?(ActionView::Base)
