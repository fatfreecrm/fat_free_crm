require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Accounts', %q{
  In order to increase customer satisfaction
  As a user
  I want to manage accounts
} do

  before(:each) do
   do_login_if_not_already(:first_name => 'Bill', :last_name => 'Murray')
  end

  scenario 'should view a list of accounts' do
    2.times { |i| FactoryGirl.create(:account, :name => "Account #{i}") }
    visit accounts_page
    page.should have_content('Account 0')
    page.should have_content('Account 1')
    page.should have_content('Search accounts')
    page.should have_content('Create Account')
  end

  scenario 'should create a new account', :js => true do
    visit accounts_page
    page.should have_content('Create Account')
    click_link 'Create Account'
    find("#account_name").should be_visible
    fill_in 'account_name', :with => 'My new account'
    click_link("Contact Information")
    fill_in 'account_phone', :with => '+1 2345 6789'
    fill_in 'account_website', :with => 'http://www.example.com'
    click_button 'Create Account'
    page.should have_content('My new account')
    page.should have_content('+1 2345 6789')
    page.should have_content('http://www.example.com')

    click_link "Dashboard"
    page.should have_content("Bill Murray created account My new account")
    page.should have_content("Bill Murray created address on My new account")
  end

  scenario 'should view and edit an account', :js => true do
    FactoryGirl.create(:account, :name => "A new account")
    visit accounts_page
    click_link 'A new account'
    page.should have_content('A new account')
    click_link 'Edit'
    fill_in 'account_name', :with => 'A new account *editted*'
    click_button 'Save Account'
    page.should have_content('A new account *editted*')

    click_link "Dashboard"
    page.should have_content("Bill Murray viewed account A new account *editted*")
    page.should have_content("Bill Murray updated account A new account *editted*")
  end

  scenario 'should delete an account', :js => true do
    FactoryGirl.create(:account, :name => "My new account")
    visit accounts_page
    click_link 'My new account'
    click_link 'Delete?'
    page.should have_content('Are you sure you want to delete this account?')
    click_link 'Yes'
    page.should have_content('My new account has been deleted')
  end

  scenario 'should search for an account', :js => true do
    2.times { |i| FactoryGirl.create(:account, :name => "Account #{i}") }
    visit accounts_page
    find('#accounts').should have_content("Account 0")
    find('#accounts').should have_content("Account 1")
    fill_in 'query', :with => "Account 0"
    find('#accounts').should have_content("Account 0")
    find('#accounts').has_selector?('li', :count => 1)
    fill_in 'query', :with => "Account"
    find('#accounts').should have_content("Account 0")
    find('#accounts').should have_content("Account 1")
    find('#accounts').has_selector?('li', :count => 2)
    fill_in 'query', :with => "Contact"
    find('#accounts').has_selector?('li', :count => 0)
  end
end
