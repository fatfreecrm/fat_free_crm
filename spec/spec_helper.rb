# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'rubygems'

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'paper_trail/frameworks/rspec'

require 'acts_as_fu'
require 'factory_bot_rails'
require 'ffaker'
require 'timecop'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

# Load shared behavior modules to be included by Runner config.
Dir["./spec/shared/**/*.rb"].sort.each { |f| require f }

TASK_STATUSES = %w[pending assigned completed].freeze

I18n.locale = 'en-US'

Paperclip.options[:log] = false

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.mock_with :rspec

  config.fixture_path = "#{Rails.root}/spec/fixtures"

  # RSpec configuration options for Fat Free CRM.
  config.include RSpec::Rails::Matchers
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :features
  config.include Warden::Test::Helpers
  config.include DeviseHelpers
  config.include FeatureHelpers

  Warden.test_mode!

  config.before(:each) do
    # Overwrite locale settings within "config/settings.yml" if necessary.
    # In order to ensure that test still pass if "Setting.locale" is not set to "en-US".
    I18n.locale = 'en-US'
    Setting.locale = 'en-US' unless Setting.locale == 'en-US'
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, :truncate) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end

ActionView::TestCase::TestController.class_eval do
  def controller_name
    HashWithIndifferentAccess.new(request.path_parameters)["controller"].split('/').last
  end
end

ActionView::Base.class_eval do
  def controller_name
    HashWithIndifferentAccess.new(request.path_parameters)["controller"].split('/').last
  end

  def called_from_index_page?(controller = controller_name)
    request.referer =~ if controller != "tasks"
                         %r{/#{controller}$}
                       else
                         /tasks\?*/
                       end
  end

  def called_from_landing_page?(controller = controller_name)
    request.referer =~ %r{/#{controller}/\w+}
  end
end
