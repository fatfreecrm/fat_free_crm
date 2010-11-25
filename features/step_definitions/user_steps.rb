Given /^a user(?: with attributes:)?$/ do |attributes|
  @user = Factory(:user, attributes.rows_hash)
end

Given /^a logged in (?:(.*) )?user$/ do |role|
  @user = Factory(:user, :admin => (role == 'Admin'))
  visit login_path
  fill_in('authentication[username]', :with => @user.username)
  fill_in('authentication[password]', :with => 'password')
  click_button('Login')
end
