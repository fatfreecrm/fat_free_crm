require 'features/acceptance_helper'

feature 'Devise Sign-up' do
  scenario 'with valid credentials' do
    visit "/users/sign_up"

    fill_in "user[email]", with: "john@example.com"
    fill_in "user[username]", with: "john"
    fill_in "user[password]", with: "password"
    fill_in "user[password_confirmation]", with: "password"
    click_button("Sign Up")

    current_path.should == "/users/sign_in"
    page.should have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
  end

  scenario 'without credentials' do
    visit "/users/sign_up"
    click_button("Sign Up")

    page.should have_content("6 errors prohibited this User from being saved")
    page.should have_content("Please specify email address")
    page.should have_content("Email is too short (minimum is 3 characters)")
    page.should have_content("Email is invalid")
    page.should have_content("Please specify username")
    page.should have_content("Username is invalid")
    page.should have_content("Password can't be blank")
  end
end
