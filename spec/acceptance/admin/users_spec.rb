require File.expand_path("../../acceptance_helper.rb", __FILE__)

feature 'Users tab', %q{
  In order to increase customer satisfaction
  As an administrator
  I want to manage users
} do

  before(:each) do
   do_login(:first_name => 'Captain', :last_name => 'Kirk', :admin => true)
  end

  scenario 'should create a new user', :js => true  do
    FactoryGirl.create(:group, :name => "Superheroes")
    visit admin_users_path
    click_link 'Create User'
    page.should have_selector('#user_username', :visible => true)
    fill_in 'user_username', :with => 'captainthunder'
    fill_in 'user_email', :with => 'lightning@example.com'
    fill_in 'user_first_name', :with => 'Captain'
    fill_in 'user_last_name', :with => 'Thunder'
    fill_in 'user_title', :with => 'Chief'
    fill_in 'user_company', :with => 'Weather Inc.'
    chosen_select('Superheroes', :from => 'user_group_ids')

    click_button 'Create User'
    page.should have_content('Captain Thunder')
    page.should have_content('Weather Inc.')
    page.should have_content('Superheroes')
    page.should have_content('lightning@example.com')

  end

end
