# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path('../boot', __FILE__)

require 'rubygems'
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

# Override Rails Engines so that plugins have higher priority than the Application
require 'fat_free_crm/gem_ext/rails/engine'

module FatFreeCRM
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Models are organized in sub-directories
    config.autoload_paths += Dir[Rails.root.join("app/models/**")] +
                             Dir[Rails.root.join("app/controllers/entities")]

    # Prevent Field class from being reloaded more than once as this clears registered customfields
    config.autoload_once_paths += [File.expand_path("../app/models/fields/field.rb", __FILE__)]

    # Activate observers that should always be running.
    unless ARGV.join.include?('assets:precompile')
      config.active_record.observers = :lead_observer, :opportunity_observer, :task_observer, :entity_observer
    end

    # Load development rake tasks (RSpec, Gem packaging, etc.)
    rake_tasks do
      Dir.glob(Rails.root.join('lib', 'development_tasks', '*.rake')).each {|t| load t }
    end

    # Add migrations from all engines
    Railties.engines.each do |engine|
      config.paths['db/migrate'] += engine.paths['db/migrate'].existent
    end

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_hash, :password_salt, :password_confirmation]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Don't initialize Rails environment
    config.assets.initialize_on_precompile = false

    # Which extra assets to precompile
    config.assets.precompile += %w(print.css)

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end

# Require fat_free_crm after FatFreeCRM::Application class is defined,
# so that FatFreeCRM::Engine is skipped.
require 'fat_free_crm'
