# #----------------------------------------------------------------------------
# # Note: Authentication is NOT ActiveRecord model, so we mock and stub it using RSpec.
#----------------------------------------------------------------------------
def login(user_stubs = {}, session_stubs = {})
  @current_user = FactoryGirl.create(:user, user_stubs)
  sign_in(:user, @current_user)
  #set_timezone
  @current_user
end

# def login_test_user
#   #mock up an authentication in warden as per http://www.michaelharrison.ws/weblog/?p=349
#   request.env['warden'] = mock(Warden, :authenticate => login,
#                                        :authenticate! => login,
#                                        :authenticate? => login)
# end
# alias :require_user :login_test_user


#----------------------------------------------------------------------------
def login_and_assign(user_stubs = {}, session_stubs = {})
  login(user_stubs, session_stubs)
  @controller.stub!(:current_user).and_return(@current_user)
  @current_user
end
 

# #----------------------------------------------------------------------------
# def logout
#   @current_user = nil
#   @current_user_session = nil
#   Authentication.stub!(:find).and_return(nil)
# end
# alias :require_no_user :logout
# 
