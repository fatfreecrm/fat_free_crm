# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path("../../acceptance_helper.rb", __FILE__)

feature 'Groups tab', '
  In order to increase customer satisfaction
  As an administrator
  I want to manage groups
' do
  before(:each) do
    do_login(first_name: 'Captain', last_name: 'Kirk', admin: true)
  end

  scenario 'should create a new group', js: true do
    create(:user, first_name: "Mr", last_name: "Spock")
    visit admin_groups_path
    expect(page).to have_content("Couldn't find any Groups.")
    click_link 'create a new group'
    expect(page).to have_selector('#group_name', visible: true)
    fill_in 'group_name', with: 'The Enterprise Bridge'
    select 'Mr Spock', from: 'group_user_ids'
    click_button 'Create Group'
    expect(page).to have_content('The Enterprise Bridge')
    expect(page).to have_content('members: Mr Spock')
  end
end
