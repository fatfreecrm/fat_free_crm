require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  if ENV["COVERAGE"]
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] = 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'fuubar'

  # Load factories
  require 'factory_girl'
  require 'ffaker'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each{ |f| require File.expand_path(f) }

  # Load shared behavior modules to be included by Runner config.
  Dir[File.dirname(__FILE__) + "/shared/*.rb"].each{ |f| require File.expand_path(f) }

  TASK_STATUSES = %w(pending assigned completed).freeze

  I18n.locale = 'en-US'

  Paperclip.options[:log] = false

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    config.fixture_path = "#{Rails.root}/spec/fixtures"

    # RSpec configuration options for Fat Free CRM.
    config.include RSpec::Rails::Matchers
    config.include(SharedControllerSpecs, :type => :controller)
    config.include(SharedModelSpecs,      :type => :model)

    config.before(:each) do
      PaperTrail.enabled = false

      # Overwrite locale settings within "config/settings.yml" if necessary.
      # In order to ensure that test still pass if "Setting.locale" is not set to "en-US".
      I18n.locale = 'en-US'
      Setting.locale = 'en-US' unless Setting.locale == 'en-US'
    end

    config.after(:each, :type => :view) do
      # detect html-quoted entities in all rendered responses
      rendered.should_not match(/&amp;[A-Za-z]{1,6};/) if rendered
    end


    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false
    config.before :suite do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end
    config.before :all, :type => :request do
      DatabaseCleaner.clean_with(:truncation)
    end
    config.around :each, :type => :request do |example|
      DatabaseCleaner.strategy = :truncation
      example.run
      DatabaseCleaner.strategy = :transaction
    end
    config.around :each do |example|
      DatabaseCleaner.start
      example.run
      DatabaseCleaner.clean
    end

    # Fuubar formatter doesn't work too well on Travis
    config.formatter = ENV["TRAVIS"] ? :progress : "Fuubar"

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
  end

  ActionView::TestCase::TestController.class_eval do
    def controller_name
      request.path_parameters["controller"].split('/').last
    end
  end

  ActionView::Base.class_eval do
    def controller_name
      HashWithIndifferentAccess.new(request.path_parameters)["controller"].split('/').last
    end

    def called_from_index_page?(controller = controller_name)
      if controller != "tasks"
        request.referer =~ %r(/#{controller}$)
      else
        request.referer =~ /tasks\?*/
      end
    end

    def called_from_landing_page?(controller = controller_name)
      request.referer =~ %r(/#{controller}/\w+)
    end
  end

end # Spork.prefork


Spork.each_run do
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end
