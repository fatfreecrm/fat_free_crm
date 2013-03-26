# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Contacts', %q{
  In order to increase customer satisfaction
  As a user
  I want to manage contacts
} do

  before :each do
    do_login_if_not_already(:first_name => "Bill", :last_name => "Murray")
  end

  scenario 'should view a list of contacts' do
    4.times { |i| FactoryGirl.create(:contact, :first_name => "Test", :last_name => "Subject \##{i}") }
    visit contacts_page
    page.should have_content('Test Subject #0')
    page.should have_content('Test Subject #1')
    page.should have_content('Test Subject #2')
    page.should have_content('Test Subject #3')
    page.should have_content('Create Contact')
  end

  scenario 'should create a contact', :js => true do
    visit contacts_page
    click_link 'Create Contact'
    page.should have_selector('#contact_first_name', :visible => true)
    fill_in 'contact_first_name', :with => 'Testy'
    fill_in 'contact_last_name', :with => 'McTest'
    fill_in 'contact_email', :with => "testy.mctest@example.com"
    fill_in 'contact_phone', :with => '+44 1234 567890'
    click_link 'Comment'
    fill_in 'comment_body', :with => 'This is a very important person.'
    click_button 'Create Contact'
    find('div#contacts').should have_content('Testy McTest')
    find('div#contacts').click_link 'Testy McTest'
    page.should have_content('This is a very important person.')
    click_link "Dashboard"
    page.should have_content('Bill Murray created contact Testy McTest')
    page.should have_content('Bill Murray created comment on Testy McTest')
  end

  scenario "remembers the comment field when the creation was unsuccessful", :js => true do
    visit contacts_page
    click_link 'Create Contact'

    click_link 'Comment'
    fill_in 'comment_body', :with => 'This is a very important person.'
    click_button 'Create Contact'

    page.should have_field("comment_body", :with => 'This is a very important person.')
  end

  scenario 'should view and edit a contact', :js => true do
    FactoryGirl.create(:contact, :first_name => "Testy", :last_name => "McTest")
    visit contacts_page
    click_link 'Testy McTest'
    click_link 'Edit'
    fill_in 'contact_first_name', :with => 'Test'
    fill_in 'contact_last_name', :with => 'Subject'
    fill_in 'contact_email', :with => "test.subject@example.com"
    click_button 'Save Contact'
    page.should have_content('Test Subject')
    click_link 'Dashboard'
    page.should have_content("Bill Murray updated contact Test Subject")
  end

  scenario 'should delete a contact', :js => true do
    FactoryGirl.create(:contact, :first_name => "Test", :last_name => "Subject")
    visit contacts_page
    click_link 'Test Subject'
    click_link 'Delete?'
    page.should have_content('Are you sure you want to delete this contact?')
    click_link 'Yes'
    page.should have_content('Test Subject has been deleted.')
    page.should_not have_content('Test Subject')
  end

  scenario 'should search for a contact', :js => true do
    2.times { |i| FactoryGirl.create(:contact, :first_name => "Test", :last_name => "Subject \##{i}") }
    visit contacts_page
    find('#contacts').should have_content('Test Subject #0')
    find('#contacts').should have_content('Test Subject #1')
    fill_in 'query', :with => 'Test Subject #1'
    find('#contacts').should have_content('Test Subject #1')
    find('#contacts').should_not have_content('Test Subject #0')
    fill_in 'query', :with => 'Test Subject'
    find('#contacts').should have_content('Test Subject #0')
    find('#contacts').should have_content('Test Subject #1')
    fill_in 'query', :with => "Fake contact"
    find('#contacts').should_not have_content('Test Subject #0')
    find('#contacts').should_not have_content('Test Subject #1')
  end
end
