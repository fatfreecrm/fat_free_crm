# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'features/acceptance_helper'

feature 'Accounts', '
  In order to increase customer satisfaction
  As a user
  I want to manage accounts
' do
  before(:each) do
    self.class.include FatFreeCrm::Engine.routes.url_helpers
    do_login_if_not_already(first_name: 'Bill', last_name: 'Murray')
  end

  scenario 'should view a list of accounts' do
    2.times { |i| create(:account, name: "Account #{i}") }
    visit accounts_page
    expect(page).to have_content('Account 0')
    expect(page).to have_content('Account 1')
    expect(page).to have_content('Create Account')
  end

  scenario 'should create a new account', js: true do
    with_versioning do
      visit accounts_page
      expect(page).to have_content('Create Account')
      click_link 'Create Account'
      expect(page).to have_selector('#account_name', visible: true)
      fill_in 'account_name', with: 'My new account'
      select 'Branch', from: 'account_category'
      select 'Myself', from: 'account_assigned_to'
      find("summary", text: 'Contact Information').click
      fill_in 'account_phone', with: '+1 2345 6789'
      fill_in 'account_website', with: 'http://www.example.com'
      find("summary", text: 'Comment').click
      fill_in 'comment_body', with: 'This account is very important'
      click_submit_and_await_form_transition("Create Account", "form.new_account")

      expect(find('ul#accounts')).to have_content('My new account')
      find('ul#accounts').click_link('My new account') # avoid recent items link
      expect(page).to have_content('+1 2345 6789')
      expect(page).to have_content('http://www.example.com')
      expect(page).to have_content('This account is very important')
      expect(page).to have_content('Branch')

      click_link "Dashboard"
      expect(page).to have_content("Bill Murray created account My new account")
      expect(page).to have_content("Bill Murray created comment on My new account")
    end
  end

  scenario "remembers the comment field when the creation was unsuccessful", js: true do
    visit accounts_page
    expect(page).to have_content('Create Account')
    click_link_and_await_form_load('Create Account', "form.new_account")

    find("summary", text: 'Contact Information').click
    fill_in 'account_phone', with: '+1 2345 6789'

    find("summary", text: 'Comment').click
    fill_in 'comment_body', with: 'This account is very important'
    click_submit_and_fail_form_transition("Create Account", "form.new_account", 10)

    find("summary", text: "Contact Information").click
    find("summary", text: "Comment").click

    expect(page).to have_field("account_phone", with: '+1 2345 6789')
    expect(page).to have_field("comment_body", with: 'This account is very important')
  end

  scenario 'should view and edit an account', js: true, versioning: true do
    create(:account, name: "A new account")
    with_versioning do
      visit accounts_page
      find('ul#accounts').click_link('A new account')
      expect(page).to have_content('A new account')
      click_link 'Edit'
      fill_in 'account_name', with: 'An updated account'
      click_submit_and_await_form_transition("Save Account", "form.edit_account", 15)

      visit_dashboard
      expect(page).to have_content("Bill Murray updated account An updated account")
    end
  end

  scenario 'should delete an account', js: true do
    create(:account, name: "My new account")
    visit accounts_page
    find('ul#accounts').click_link('My new account')
    click_link 'Delete'
    expect(page).to have_content('Are you sure you want to delete this account?')
    click_link 'Yes'
    expect(page).to have_content('My new account has been deleted')
  end

  scenario 'should search for an account', js: true do
    2.times { |i| create(:account, name: "Account #{i}") }
    visit accounts_page
    expect(find('#accounts')).to have_content("Account 0")
    expect(find('#accounts')).to have_content("Account 1")
    fill_in 'query', with: "Account 0"
    expect(find('#accounts')).to have_content("Account 0")
    expect(find('#accounts')).not_to have_content("Account 1")
    fill_in 'query', with: "Account"
    expect(find('#accounts')).to have_content("Account 0")
    expect(find('#accounts')).to have_content("Account 1")
    fill_in 'query', with: "Contact"
    expect(find('#accounts')).not_to have_content("Account 0")
    expect(find('#accounts')).not_to have_content("Account 1")
  end

  scenario 'should attach task to account', js: true, versioning: true do
    create(:task, name: 'Task', user: @user)
    create(:account, name: 'Account')
    with_versioning do
      visit accounts_page
      expect(find('#accounts')).to have_content("Account")
      click_link 'Account'
      click_link 'Select Task'
      fill_autocomplete('auto_complete_query', with: 'Ta')
      expect(find('#tasks')).to have_content('Task re: Account')
    end
  end
end
