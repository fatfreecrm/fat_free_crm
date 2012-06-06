require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Accounts', %q{
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
    page.should have_content('Search contacts')
    page.should have_content('Create Contact')
  end

  scenario 'should create a contact', :js => true do
    visit contacts_page
    click_link 'Create Contact'
    fill_in 'contact_first_name', :with => 'Testy'
    fill_in 'contact_last_name', :with => 'McTest'
    fill_in 'contact_email', :with => "testy.mctest@example.com"
    fill_in 'contact_phone', :with => '+44 1234 567890'
    click_button 'Create Contact'
    page.should have_content('Testy McTest')

    click_link "Dashboard"
    page.should have_content('Bill Murray created contact Testy McTest')
    page.should have_content('Bill Murray created address on Testy McTest')
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
    click_link 'Contacts'
    page.should have_content('Test Subject')

    click_link 'Dashboard'
    page.should have_content("Bill Murray viewed contact Test Subject")
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
    click_link('Contacts')
    page.should_not have_content('Test Subject')
  end

  scenario 'should search for a contact', :js => true do
    3.times { |i| FactoryGirl.create(:contact, :first_name => "Test", :last_name => "Subject \##{i}") }
    visit contacts_page
    find('#contacts').should have_content('Test Subject #0')
    find('#contacts').should have_content('Test Subject #1')
    find('#contacts').should have_content('Test Subject #2')
    fill_in 'query', :with => 'Test Subject #2'
    find('#contacts').should have_content('Test Subject #2')
    find('#contacts').has_selector?('li', :count => 1)
    fill_in 'query', :with => 'Test Subject'
    find('#contacts').should have_content('Test Subject #0')
    find('#contacts').should have_content('Test Subject #1')
    find('#contacts').should have_content('Test Subject #2')
    find('#contacts').has_selector?('li', :count => 3)
    fill_in 'query', :with => "Fake contact"
    find('#contacts').has_selector?('li', :count => 0)
  end
end