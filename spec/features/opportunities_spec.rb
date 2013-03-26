# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Opportunities', %q{
  In order to increase sales
  As a user
  I want to manage opportunities
} do

  before :each do
    do_login_if_not_already(:first_name => 'Bill', :last_name => 'Murray')
  end

  scenario 'should view a list of opportunities' do
    3.times { |i| FactoryGirl.create(:opportunity, :name => "Opportunity #{i}") }
    visit opportunities_page
    page.should have_content('Opportunity 0')
    page.should have_content('Opportunity 1')
    page.should have_content('Opportunity 2')
    page.should have_content('Create Opportunity')
  end

  scenario 'should create a new opportunity', :js => true do
    FactoryGirl.create(:account, :name => 'Example Account')
    visit opportunities_page
    click_link 'Create Opportunity'
    page.should have_selector('#opportunity_name', :visible => true)
    fill_in 'opportunity_name', :with => 'My Awesome Opportunity'
    fill_in 'account_name', :with => 'Example Account'
    select 'Prospecting', :from => 'opportunity_stage'
    click_link 'Comment'
    fill_in 'comment_body', :with => 'This is a very important opportunity.'
    click_button 'Create Opportunity'
    page.should have_content('My Awesome Opportunity')

    find('div#opportunities').click_link('My Awesome Opportunity')
    page.should have_content('This is a very important opportunity.')

    click_link "Dashboard"
    page.should have_content("Bill Murray created opportunity My Awesome Opportunity")
    page.should have_content("Bill Murray created comment on My Awesome Opportunity")
  end

  scenario "remembers the comment field when the creation was unsuccessful", :js => true do
    visit opportunities_page
    click_link 'Create Opportunity'
    select 'Prospecting', :from => 'opportunity_stage'

    click_link 'Comment'
    fill_in 'comment_body', :with => 'This is a very important opportunity.'
    click_button 'Create Opportunity'

    page.should have_field('comment_body', :with => 'This is a very important opportunity.')
  end

  scenario 'should view and edit an opportunity', :js => true do
    FactoryGirl.create(:account, :name => 'Example Account')
    FactoryGirl.create(:account, :name => 'Other Example Account')
    FactoryGirl.create(:opportunity, :name => 'A Cool Opportunity')
    visit opportunities_page
    click_link 'A Cool Opportunity'
    click_link 'Edit'
    fill_in 'opportunity_name', :with => 'An Even Cooler Opportunity'
    chosen_select('Other Example Account', :from => 'account_id')
    select 'Analysis', :from => 'opportunity_stage'
    click_button 'Save Opportunity'
    page.should have_content('An Even Cooler Opportunity')
    click_link "Dashboard"
    page.should have_content("Bill Murray updated opportunity An Even Cooler Opportunity")
  end

  scenario 'should delete an opportunity', :js => true do
    FactoryGirl.create(:opportunity, :name => 'Outdated Opportunity')
    visit opportunities_page
    click_link 'Outdated Opportunity'
    click_link 'Delete?'
    page.should have_content('Are you sure you want to delete this opportunity?')
    click_link 'Yes'
    page.should have_content('Outdated Opportunity has been deleted.')
  end

  scenario 'should search for an opportunity', :js => true do
    2.times { |i| FactoryGirl.create(:opportunity, :name => "Opportunity #{i}") }
    visit opportunities_page
    find('#opportunities').should have_content("Opportunity 0")
    find('#opportunities').should have_content("Opportunity 1")
    fill_in 'query', :with => "Opportunity 0"
    find('#opportunities').should have_content("Opportunity 0")
    find('#opportunities').should_not have_content("Opportunity 1")
    fill_in 'query', :with => "Opportunity"
    find('#opportunities').should have_content("Opportunity 0")
    find('#opportunities').should have_content("Opportunity 1")
    fill_in 'query', :with => "Non-existant opportunity"
    find('#opportunities').should_not have_content("Opportunity 0")
    find('#opportunities').should_not have_content("Opportunity 1")
  end
end
