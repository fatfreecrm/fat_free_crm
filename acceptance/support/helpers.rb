module HelperMethods
  # Put helper methods you need to be available in all acceptance specs here.

  def do_login(args = {})
    user = Factory(:user, args)
    visit '/login'
    fill_in "authentication_username", :with => user.username
    fill_in "authentication_password", :with => user.password
    click_button "Login"
  end
 
end

RSpec.configuration.include HelperMethods, :type => :acceptance
