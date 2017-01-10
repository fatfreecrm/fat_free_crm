# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
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
  User.current_user = @current_user = FactoryGirl.create(:user, user_stubs)
  @current_user_session = double(Authentication, { record: current_user }.merge(session_stubs))
  allow(Authentication).to receive(:find).and_return(@current_user_session)
  # set_timezone
end
alias :require_user :login

#----------------------------------------------------------------------------
def login_and_assign(user_stubs = {}, session_stubs = {})
  User.current_user = @current_user = FactoryGirl.build_stubbed(:user, user_stubs)
  @current_user_session = double(Authentication, { record: current_user }.merge(session_stubs))
  allow(Authentication).to receive(:find).and_return(@current_user_session)
  # set_timezone
  assigns[:current_user] = current_user
end

def login_and_assign!(_user_stubs = {}, _session_stubs = {})
  login
  assigns[:current_user] = current_user
end

#----------------------------------------------------------------------------
def logout
  @current_user = nil
  @current_user_session = nil
  allow(Authentication).to receive(:find).and_return(nil)
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
