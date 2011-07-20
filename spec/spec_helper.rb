# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'factory_girl'
require "#{::Rails.root}/spec/factories"

# Load factories from plugins (to allow extra validations / etc.)
Dir.glob("vendor/plugins/**/spec/factories.rb").each{ |f| require File.expand_path(f) }


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Load shared behavior modules to be included by Runner config.
Dir[File.dirname(__FILE__) + "/shared/*.rb"].map {|f| require f}

TASK_STATUSES = %w(pending assigned completed).freeze

# Load default settings from config/settings.yml
Factory(:default_settings)
Setting.task_calendar_with_time = false

I18n.locale = 'en-US'

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include RSpec::Rails::Matchers

  # RSpec configuration options for Fat Free CRM.
  config.include RSpec::Rails::Matchers
  config.include(SharedControllerSpecs, :type => :controller)
  config.include(SharedModelSpecs,      :type => :model)

  config.before(:each, :type => :view) do
    I18n.locale = 'en-US'
  end

  config.after(:each, :type => :view) do
    # detect html-quoted entities in all rendered responses
    rendered.should_not match(/&amp;[A-Za-z]{1,6};/) if rendered
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

# See vendor/plugins/authlogic/lib/authlogic/test_case.rb
#----------------------------------------------------------------------------
def activate_authlogic
  require 'authlogic/test_case/rails_request_adapter'
  require 'authlogic/test_case/mock_cookie_jar'
  require 'authlogic/test_case/mock_request'

  Authlogic::Session::Base.controller = (@request && Authlogic::TestCase::RailsRequestAdapter.new(@request)) || controller
end

# Note: Authentication is NOT ActiveRecord model, so we mock and stub it using RSpec.
#----------------------------------------------------------------------------
def login(user_stubs = {}, session_stubs = {})
  User.current_user = @current_user = Factory(:user, user_stubs)
  @current_user_session = mock(Authentication, {:record => @current_user}.merge(session_stubs))
  Authentication.stub!(:find).and_return(@current_user_session)
  #set_timezone
end
alias :require_user :login

#- ---------------------------------------------------------------------------
def login_and_assign(user_stubs = {}, session_stubs = {})
  login(user_stubs, session_stubs)
  assigns[:current_user] = @current_user
end

#----------------------------------------------------------------------------
def logout
  @current_user = nil
  @current_user_session = nil
  Authentication.stub!(:find).and_return(nil)
end
alias :require_no_user :logout

#----------------------------------------------------------------------------
def current_user
  @current_user
end

#----------------------------------------------------------------------------
def current_user_session
  @current_user_session
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
  settings.inject({ :all => 0 }) { |hash, key| hash[key] = 1; hash }
end

# Get current server timezone and set it (see rake time:zones:local for details).
#----------------------------------------------------------------------------
def set_timezone
  offset = [ Time.now.beginning_of_year.utc_offset, Time.now.beginning_of_year.change(:month => 7).utc_offset ].min
  offset *= 3600 if offset.abs < 13
  Time.zone = ActiveSupport::TimeZone.all.select { |zone| zone.utc_offset == offset }.first
end

# Adjusts current timezone by given offset (in seconds).
#----------------------------------------------------------------------------
def adjust_timezone(offset)
  if offset
    ActiveSupport::TimeZone[offset]
    adjusted_time = Time.now + offset.seconds
    Time.stub(:now).and_return(adjusted_time)
  end
end

ActionView::TestCase::TestController.class_eval do
  def self.controller_name
    controller_path.split("/").last
  end
end

if RUBY_VERSION.to_f >= 1.9
  RSpec::Rails::ViewExampleGroup::InstanceMethods.module_eval do
    def render_with_mock_response(*args)
      render_without_mock_response *args
      @response = mock(:body => rendered)
    end
    alias_method_chain :render, :mock_response
  end
else
  RSpec::Rails::ViewExampleGroup::InstanceMethods.module_eval do
    # Ruby 1.8.x doesnt support alias_method_chain with blocks,
    # so we are just overwriting the whole method verbatim.
    def render(options={}, local_assigns={}, &block)
      options = {:template => _default_file_to_render} if Hash === options and options.empty?
      super(options, local_assigns, &block)
      @response = mock(:body => rendered)
    end
  end
end

ActionView::Base.class_eval do
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
