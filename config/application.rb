# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require_relative 'boot'

require 'rubygems'
require 'rails/all'

# Pick the frameworks you want:
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require 'ransack'

# require "rails/test_unit/railtie"
#
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Override Rails Engines so that plugins have higher priority than the Application
require 'fat_free_crm/gem_ext/rails/engine'

module FatFreeCRM
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Models are organized in sub-directories
    config.autoload_paths += Dir[Rails.root.join("app/models/**")] +
                             Dir[Rails.root.join("app/controllers/entities")]

    # Prevent Field class from being reloaded more than once as this clears registered customfields
    config.autoload_once_paths += [File.expand_path('app/models/fields/field.rb', __dir__)]

    # Activate observers that should always be running.
    config.active_record.observers = :lead_observer, :opportunity_observer, :task_observer, :entity_observer unless ARGV.join.include?('assets:precompile')

    # Load development rake tasks (RSpec, Gem packaging, etc.)
    rake_tasks do
      Dir.glob(Rails.root.join('lib', 'development_tasks', '*.rake')).each { |t| load t }
    end

    # Add migrations from all engines
    # Railties.engines.each do |engine|
    #   # config.paths['db/migrate'] += engine.paths['db/migrate'].existent
    # end

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
    config.filter_parameters += %i[password encrypted_password password_salt password_confirmation]

    # Enable support for loading via Psych, required by PaperTrail
    config.active_record.use_yaml_unsafe_load = false
    config.active_record.yaml_column_permitted_classes = [
      ::ActiveRecord::Type::Time::Value,
      ::ActiveSupport::HashWithIndifferentAccess, # for Field#settings serialization see app/models/fields/field.rb
      ::ActiveSupport::TimeWithZone,
      ::ActiveSupport::TimeZone,
      ::BigDecimal,
      ::Date,
      ::Symbol,
      ::Time
    ]
  end
end

# Require fat_free_crm after FatFreeCRM::Application class is defined,
# so that FatFreeCRM::Engine is skipped.
require 'fat_free_crm'
