# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'features/acceptance_helper'

feature 'Devise Sign-in' do
  background do
    Setting.user_signup = :needs_approval
    @user = create :user,
                   username: 'john',
                   password: 'password',
                   password_confirmation: 'password',
                   email: 'john@example.com',
                   sign_in_count: 0
  end

  scenario 'without confirmation' do
    login_process('john', 'password')
    expect(page).to have_content("You have to confirm your email address before continuing.")
  end

  scenario 'without approval' do
    @user.confirm
    login_process('john', 'password')
    expect(page).to have_content("Your account has not been approved yet.")
  end

  scenario 'with approved and confirmed account' do
    @user.confirm
    @user.update_attribute(:suspended_at, nil)
    login_process('john', 'password')
    expect(page).to have_content("Signed in successfully.")
  end

  scenario 'invalid credentials' do
    login_process('jo', 'pass')
    expect(current_path).to eq "/users/sign_in"
    expect(page).to have_content("Invalid Email or password")
  end

  scenario 'login with email' do
    @user.confirm
    @user.update_attribute(:suspended_at, nil)
    login_process('john@example.com', 'password')
    expect(page).to have_content("Signed in successfully")
  end

  def login_process(username, password)
    visit '/users/sign_in'
    fill_in 'user[email]', with: username
    fill_in 'user[password]', with: password
    click_button 'Login'
  end
end
