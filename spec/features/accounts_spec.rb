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
      select2 'Affiliate', from: 'Category:'
      select2 'Myself', from: 'Assigned to:'
      click_link 'Contact Information'
      fill_in 'account_phone', with: '+1 2345 6789'
      fill_in 'account_website', with: 'http://www.example.com'
      click_link 'Comment'
      fill_in 'comment_body', with: 'This account is very important'
      click_button 'Create Account'

      expect(find('div#accounts')).to have_content('My new account')
      find('div#accounts').click_link('My new account') # avoid recent items link
      expect(page).to have_content('+1 2345 6789')
      expect(page).to have_content('http://www.example.com')
      expect(page).to have_content('This account is very important')
      expect(page).to have_content('Affiliate')

      click_link "Dashboard"
      expect(page).to have_content("Bill Murray created account My new account")
      expect(page).to have_content("Bill Murray created comment on My new account")
    end
  end

  scenario "remembers the comment field when the creation was unsuccessful", js: true do
    visit accounts_page
    expect(page).to have_content('Create Account')
    click_link 'Create Account'

    click_link 'Contact Information'
    fill_in 'account_phone', with: '+1 2345 6789'

    click_link 'Comment'
    fill_in 'comment_body', with: 'This account is very important'
    click_button "Create Account"

    expect(page).to have_field("account_phone", with: '+1 2345 6789')
    expect(page).to have_field("comment_body", with: 'This account is very important')
  end

  scenario 'should view and edit an account', js: true, versioning: true do
    create(:account, name: "A new account")
    with_versioning do
      visit accounts_page
      find('div#accounts').click_link('A new account')
      expect(page).to have_content('A new account')
      click_link 'Edit'
      fill_in 'account_name', with: 'A new account *editted*'
      click_button 'Save Account'
      expect(page).to have_content('A new account *editted*')

      click_link "Dashboard"
      expect(page).to have_content("Bill Murray updated account A new account *editted*")
    end
  end

  scenario 'should delete an account', js: true do
    create(:account, name: "My new account")
    visit accounts_page
    find('div#accounts').click_link('My new account')
    click_link 'Delete?'
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
