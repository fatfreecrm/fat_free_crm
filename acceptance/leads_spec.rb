require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Leads', %q{
  In order to increase sales
  As a user
  I want to manage leads
} do

  before(:each) do
   do_login_if_not_already(:first_name => 'Bill', :last_name => 'Murray')
  end

  scenario 'should view a list of leads' do
    4.times { |i| FactoryGirl.create(:lead, :first_name => "L", :last_name => "Ead #{i}") }
    visit leads_page
    page.should have_content('L Ead 0')
    page.should have_content('L Ead 1')
    page.should have_content('L Ead 2')
    page.should have_content('L Ead 3')
    page.should have_content('Search leads')
    page.should have_content('Create Lead')
  end

  scenario 'should create a new lead', :js => true do
    visit leads_page
    click_link 'Create Lead'
    fill_in 'lead_first_name', :with => 'Mr'
    fill_in 'lead_last_name', :with => 'Lead'
    fill_in 'lead_email', :with => 'mr_lead@example.com'
    fill_in 'lead_phone', :with => '+44 1234 567890'
    click_link('Status')
    select 'Contacted', :from => 'lead_status'
    click_button 'Create Lead'
    page.should have_content('Mr Lead')
    page.should have_content('Contacted')
    page.should have_content('mr_lead@example.com')
    page.should have_content('+44 1234 567890')

    click_link "Dashboard"
    page.should have_content("Bill Murray created lead Mr Lead")
  end

  scenario 'should view and edit a lead', :js => true do
    FactoryGirl.create(:lead, :first_name => "Mr", :last_name => "Lead", :email => "mr_lead@example.com")
    visit leads_page
    click_link 'Mr Lead'
    page.should have_content('Mr Lead')
    click_link('Edit')
    fill_in 'lead_first_name', :with => 'Mrs'
    fill_in 'lead_phone', :with => '+44 0987 654321'
    click_link('Status')
    select 'Rejected', :from => 'lead_status'
    click_button 'Save Lead'
    page.should have_content('Mrs Lead')
    click_link 'Leads'
    page.should have_content('Mrs Lead')
    page.should have_content('Rejected')
    page.should have_content('mr_lead@example.com')
    page.should have_content('+44 0987 654321')

    click_link "Dashboard"
    page.should have_content("Bill Murray viewed lead Mrs Lead")
    page.should have_content("Bill Murray updated lead Mrs Lead")
  end

  scenario 'should delete a lead', :js => true do
    FactoryGirl.create(:lead, :first_name => "Mr", :last_name => "Lead", :email => "mr_lead@example.com")
    visit leads_page
    click_link 'Mr Lead'
    click_link 'Delete?'
    page.should have_content('Are you sure you want to delete this lead?')
    click_link 'Yes'
    page.should have_content('Mr Lead has been deleted.')
    click_link 'Leads'
    page.should_not have_content('Mr Lead')
    page.should_not have_content('mr_lead@example.com')
  end

  scenario 'should search for a lead', :js => true do
    3.times { |i| FactoryGirl.create(:lead, :first_name => "Lead", :last_name => "\##{i}", :email => "lead#{i}@example.com") }
    visit leads_page
    find('#leads').should have_content('Lead #0')
    find('#leads').should have_content('Lead #1')
    find('#leads').should have_content('Lead #2')
    fill_in 'query', :with => 'Lead #0'
    find('#leads').should have_content('Lead #0')
    find('#leads').has_selector?('li', :count => 1)
    fill_in 'query', :with => 'Lead'
    find('#leads').should have_content('Lead #0')
    find('#leads').should have_content('Lead #1')
    find('#leads').should have_content('Lead #2')
    find('#leads').has_selector?('li', :count => 3)
    fill_in 'query', :with => 'Non-existant lead'
    find('#leads').has_selector?('li', :count => 0)
  end
end