require 'features/acceptance_helper'

feature 'Devise Sign-in' do
  background do
    Setting.user_signup = :needs_approval
    @user = create :user,
      username: 'john',
      password: 'password',
      password_confirmation: 'password',
      sign_in_count: 0
  end

  scenario 'without confirmation' do
    login_process('john', 'password')
    page.should have_content("You have to confirm your email address before continuing.")
  end

  scenario 'without approval' do
    @user.confirm
    @user.update_attribute(:suspended_at, Time.now)
    login_process('john', 'password')
    page.should have_content("Your account has not been approved yet.")
  end

  scenario 'with approved and confirmed account' do
    @user.confirm
    @user.update_attribute(:suspended_at, nil)
    login_process('john', 'password')
    page.should have_content("Signed in successfully.")
  end

  scenario 'invalid credentials' do
    login_process('jo', 'pass')
    current_path.should == "/users/sign_in"
    # page.should have_content("Invalid Usename and Password.")
  end

  def login_process(username, password)
    visit '/users/sign_in'
    fill_in 'user[email]', with: username
    fill_in 'user[password]', with: password
    click_button 'Login'
  end
end
