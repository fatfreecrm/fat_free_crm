require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FatFreeCRM
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.generators.template_engine = :haml
    config.autoloader = :zeitwerk

    # Models are organized in sub-directories
    config.autoload_paths += Dir[Rails.root.join("app/models/**")] +
                             Dir[Rails.root.join("app/controllers/entities")]

    # Prevent Field class from being reloaded more than once as this clears registered customfields
    config.autoload_once_paths += [File.expand_path('app/models/fields/field.rb', __dir__)]

    # Activate observers that should always be running.
    config.active_record.observers = :lead_observer, :opportunity_observer, :task_observer, :entity_observer unless ARGV.join.include?('assets:precompile')

    
    Dir[Rails.root.join('lib', 'development_tasks', '*.rake')].each do |task|
      load task
    end

    

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
