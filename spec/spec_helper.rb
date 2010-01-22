# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require "factory_girl"
require RAILS_ROOT + "/spec/factories"

# Load shared behavior modules to be included by Runner config.
Dir[File.dirname(__FILE__) + "/shared/*.rb"].map do |file|
  require file
end

VIEWS = %w(pending assigned completed).freeze

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.include(SharedControllerSpecs, :type => :controller)
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

# Load default settings from config/settings.yml
Factory(:default_settings)

# See vendor/plugins/authlogic/lib/authlogic/test_case.rb
#----------------------------------------------------------------------------
def activate_authlogic
  Authlogic::Session::Base.controller = (@request && Authlogic::TestCase::RailsRequestAdapter.new(@request)) || controller
end

# Note: Authentication is NOT ActiveRecord model, so we mock and stub it using RSpec.
#----------------------------------------------------------------------------
def login(user_stubs = {}, session_stubs = {})
  User.current_user = @current_user = Factory(:user, user_stubs)
  @current_user_session = mock_model(Authentication, {:record => @current_user}.merge(session_stubs))
  Authentication.stub!(:find).and_return(@current_user_session)
  set_timezone
end
alias :require_user :login

#----------------------------------------------------------------------------
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
