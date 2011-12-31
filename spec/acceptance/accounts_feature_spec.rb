require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Accounts feature', %q{
  In order to increase customer satisfaction
  As a user
  I want to manage accounts
} do

  before(:each) do
    do_login
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

end
