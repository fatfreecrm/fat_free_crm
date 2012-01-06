require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Accounts', %q{
  In order to increase customer satisfaction
  As a user
  I want to manage accounts
} do

  before(:each) do
   do_login_if_not_already
  end

  scenario 'should view a list of accounts' do
    2.times { |i| Factory(:account, :name => "Account #{i}") }
    visit accounts_path
    page.should have_content('Account 0')
    page.should have_content('Account 1')
    page.should have_content('Search accounts')
    page.should have_content('Create Account')
  end

  scenario 'should create a new account', :js => true do
    visit accounts_path
    page.should have_content('Create Account')
    click_link 'Create Account'
    fill_in 'account_name', :with => 'My new account'
    click_button 'Create Account'
    page.should have_content('My new account')
  end

  scenario 'should ajax search for an account', :js => true do
    2.times { |i| Factory(:account, :name => "Account #{i}") }
    visit accounts_path
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

  scenario 'should ajax search for an account', :js => true do
    2.times { |i| Factory(:account, :name => "Account #{i}") }
    visit accounts_path
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

  scenario 'should ajax search for an account', :js => true do
    2.times { |i| Factory(:account, :name => "Account #{i}") }
    visit accounts_path
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
