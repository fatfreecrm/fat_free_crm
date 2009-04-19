# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require "spec"
require "factory_girl"
require "spec/rails"
require RAILS_ROOT + "/spec/factories"

VIEWS = %w(pending assigned completed).freeze

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end


# Load default settings from config/settings.yml
Factory(:default_settings)

# Note: Authentication is NOT ActiveRecord model, so we mock and stub it using RSpec.
#----------------------------------------------------------------------------
def login(session_stubs = {}, user_stubs = {})
  @current_user = Factory(:user, user_stubs)
  @current_user_session = mock_model(Authentication, {:record => @current_user}.merge(session_stubs))
  Authentication.stub!(:find).and_return(@current_user_session)
end

#----------------------------------------------------------------------------
def login_and_assign
  login
  assigns[:current_user] = @current_user
end
 
#----------------------------------------------------------------------------
def logout
  @current_user = nil
  @current_user_session = nil
  Authentication.stub!(:find).and_return(nil)
end
  
#----------------------------------------------------------------------------
def current_user
  @current_user
end
 
#----------------------------------------------------------------------------
def current_user_session
  @current_user_session
end

#----------------------------------------------------------------------------
def require_user
  login
end

#----------------------------------------------------------------------------
def require_no_user
  logout
end

#----------------------------------------------------------------------------
def set_current_tab(tab)
  controller.session[:current_tab] = tab
end

#----------------------------------------------------------------------------
def stub_task(view)
  if view == "completed"
    assigns[:task] = Factory(:task, :completed_at => Time.now - 1.minute)
  elsif view == "assigned"
    assigns[:task] = Factory(:task, :assignee => Factory(:user))
  else
    assigns[:task] = Factory(:task)
  end
end

#----------------------------------------------------------------------------
def stub_task_total(view = "pending")
  settings = (view == "completed" ? Setting.task_completed : Setting.task_bucket)
  settings.inject({ :all => 0 }) { |hash, (value, key)| hash[key] = 1; hash }
end
