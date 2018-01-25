# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'features/acceptance_helper'

feature 'Devise Sign-up' do
  scenario 'with valid credentials' do
    visit "/users/sign_up"

    fill_in "user[email]", with: "john@example.com"
    fill_in "user[username]", with: "john"
    fill_in "user[password]", with: "password"
    fill_in "user[password_confirmation]", with: "password"
    click_button("Sign Up")

    expect(current_path).to eq "/users/sign_in"
    expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
  end

  scenario 'without credentials' do
    visit "/users/sign_up"
    click_button("Sign Up")

    expect(page).to have_content("6 errors prohibited this User from being saved")
    expect(page).to have_content("Please specify email address")
    expect(page).to have_content("Email is too short (minimum is 3 characters)")
    expect(page).to have_content("Email is invalid")
    expect(page).to have_content("Please specify username")
    expect(page).to have_content("Username is invalid")
    expect(page).to have_content("Password can't be blank")
  end
end
