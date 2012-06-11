module HelperMethods
  # Put helper methods you need to be available in all acceptance specs here.

  def do_login(options = {})
    @user = FactoryGirl.create(:user, options)
    visit '/login'
    fill_in "authentication_username", :with => @user.username
    fill_in "authentication_password", :with => @user.password
    click_button "Login"
  end

  def login_as_user(user)
    visit '/login'
    fill_in "authentication_username", :with => user.username
    fill_in "authentication_password", :with => user.password
    click_button "Login"
  end

  # if we're already logged in, don't bother doing it again
  def do_login_if_not_already(options = {})
    do_login(options) unless @user.present?
  end

end

RSpec.configuration.include HelperMethods, :type => :request
