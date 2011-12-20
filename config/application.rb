require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

# Override engine views so that plugin views have higher priority.
Rails::Engine.initializers.detect{|i| i.name == :add_view_paths }.
  instance_variable_set("@block", Proc.new {
    views = paths["app/views"].to_a
    unless views.empty?
      ActiveSupport.on_load(:action_controller){ append_view_path(views) }
      ActiveSupport.on_load(:action_mailer){ append_view_path(views) }
    end
  }
)

# Override I18n load paths so that plugin locales have higher priority.
Rails::Engine.initializers.detect{|i| i.name == :add_locales }.
  instance_variable_set("@block", Proc.new {
    config.i18n.railties_load_path.concat( paths["config/locales"].to_a ).reverse!
  }
)

module FatFreeCRM
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Models are organized in sub-directories
    config.autoload_paths += Dir[Rails.root.join("app/models/**")]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Don't load observers when running rake assets:precompile
    config.active_record.observers = :activity_observer unless ARGV.join.include?('assets:precompile')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'en-US'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # ActionMailer configuration.
    config.action_mailer.default :content_type => "text/plain"
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = { :location  => "/usr/sbin/sendmail", :arguments => "-i -t" }

    config.action_controller.allow_forgery_protection = false
  end
end

