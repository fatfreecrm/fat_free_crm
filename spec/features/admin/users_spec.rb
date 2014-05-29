# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

feature 'Users tab', %q{
  In order to increase customer satisfaction
  As an administrator
  I want to manage users
} do

  before(:each) do
   do_login(first_name: 'Captain', last_name: 'Kirk', admin: true)
  end

  scenario 'should create a new user', js: true  do
    FactoryGirl.create(:group, name: "Superheroes")
    visit admin_users_path
    click_link 'Create User'
    page.should have_selector('#user_username', visible: true)
    fill_in 'user_username', with: 'captainthunder'
    fill_in 'user_email', with: 'lightning@example.com'
    fill_in 'user_first_name', with: 'Captain'
    fill_in 'user_last_name', with: 'Thunder'
    fill_in 'user_password', with: 'password'
    fill_in 'user_password_confirmation', with: 'password'
    fill_in 'user_title', with: 'Chief'
    fill_in 'user_company', with: 'Weather Inc.'
    chosen_select('Superheroes', from: 'user_group_ids')
    click_button 'Create User'
    find('#users').should have_content('Captain Thunder')
    find('#users').should have_content('Weather Inc.')
    find('#users').should have_content('Superheroes')
    find('#users').should have_content('lightning@example.com')
  end
end
