# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Contacts', '
  In order to increase customer satisfaction
  As a user
  I want to manage contacts
' do
  before :each do
    do_login_if_not_already(first_name: "Bill", last_name: "Murray")
  end

  scenario 'should view a list of contacts' do
    4.times { |i| create(:contact, first_name: "Test", last_name: "Subject \##{i}") }
    visit contacts_page
    expect(contacts_element).to have_content('Test Subject #0')
    expect(contacts_element).to have_content('Test Subject #1')
    expect(contacts_element).to have_content('Test Subject #2')
    expect(contacts_element).to have_content('Test Subject #3')
    expect(page).to have_content('Create Contact')
  end

  scenario 'should create a contact', js: true do
    with_versioning do
      visit contacts_page
      click_link 'Create Contact'
      select = find('#account_name', visible: true)
      expect(select).to have_text("")
      expect(page).to have_selector('#select2-account_id-container', visible: false)
      expect(page).to have_selector('#contact_first_name', visible: true)
      fill_in 'contact_first_name', with: 'Testy'
      fill_in 'contact_last_name', with: 'McTest'
      fill_in 'contact_email', with: "testy.mctest@example.com"
      fill_in 'contact_phone', with: '+44 1234 567890'
      click_link 'Comment'
      fill_in 'comment_body', with: 'This is a very important person.'
      click_button 'Create Contact'
      expect(contacts_element).to have_content('Testy McTest')

      contacts_element.click_link 'Testy McTest'
      sleep(1) # avoid CI failure
      expect(main_element).to have_content('This is a very important person.')

      click_link "Dashboard"
      expect(activities_element).to have_content('Bill Murray created contact Testy McTest')
      expect(activities_element).to have_content('Bill Murray created comment on Testy McTest')
    end
  end

  scenario "remembers the comment field when the creation was unsuccessful", js: true do
    visit contacts_page
    click_link 'Create Contact'

    click_link 'Comment'
    fill_in 'comment_body', with: 'This is a very important person.'
    click_button 'Create Contact'

    expect(page).to have_field("comment_body", with: 'This is a very important person.')
  end

  scenario 'should view and edit a contact', js: true do
    create(:contact, first_name: "Testy", last_name: "McTest", account: create(:account, name: "Toast"))
    with_versioning do
      visit contacts_page
      click_link 'Testy McTest'
      click_link 'Edit'
      select = find('#select2-account_id-container', visible: true)
      expect(select).to have_text("Toast")
      expect(page).to have_selector('#account_name', visible: false)
      fill_in 'contact_first_name', with: 'Test'
      fill_in 'contact_last_name', with: 'Subject'
      fill_in 'contact_email', with: "test.subject@example.com"
      click_button 'Save Contact'
      expect(summary_element).to have_content('Test Subject')

      click_link 'Dashboard'
      expect(activities_element).to have_content("Bill Murray updated contact Test Subject")
    end
  end

  scenario 'should delete a contact', js: true do
    create(:contact, first_name: "Test", last_name: "Subject")
    visit contacts_page
    click_link 'Test Subject'
    click_link 'Delete?'
    expect(menu_element).to have_content('Are you sure you want to delete this contact?')
    click_link 'Yes'
    expect(flash_element).to have_content('Test Subject has been deleted.')
    expect(contacts_element).not_to have_content('Test Subject')
  end

  scenario 'should search for a contact', js: true do
    2.times { |i| create(:contact, first_name: "Test", last_name: "Subject \##{i}") }
    visit contacts_page
    expect(contacts_element).to have_content('Test Subject #0')
    expect(contacts_element).to have_content('Test Subject #1')
    fill_in 'query', with: 'Test Subject #1'
    expect(contacts_element).to have_content('Test Subject #1')
    expect(contacts_element).not_to have_content('Test Subject #0')
    fill_in 'query', with: 'Test Subject'
    expect(contacts_element).to have_content('Test Subject #0')
    expect(contacts_element).to have_content('Test Subject #1')
    fill_in 'query', with: "Fake contact"
    expect(contacts_element).not_to have_content('Test Subject #0')
    expect(contacts_element).not_to have_content('Test Subject #1')
  end

  def main_element
    find('#main')
  end

  def summary_element
    find('#summary')
  end

  def menu_element
    find('#menu')
  end

  def flash_element
    find('#flash')
  end

  def contacts_element
    find('#contacts')
  end

  def activities_element
    find('#activities')
  end
end
