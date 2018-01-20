# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Opportunities', '
  In order to increase sales
  As a user
  I want to manage opportunities
' do
  before :each do
    do_login_if_not_already(first_name: 'Bill', last_name: 'Murray')
  end

  scenario 'should view a list of opportunities' do
    3.times { |i| create(:opportunity, name: "Opportunity #{i}") }
    visit opportunities_page
    expect(page).to have_content('Opportunity 0')
    expect(page).to have_content('Opportunity 1')
    expect(page).to have_content('Opportunity 2')
    expect(page).to have_content('Create Opportunity')
  end

  scenario 'should create a new opportunity', js: true do
    create(:account, name: 'Example Account')
    with_versioning do
      visit opportunities_page
      click_link 'Create Opportunity'
      expect(page).to have_selector('#opportunity_name', visible: true)
      fill_in 'opportunity_name', with: 'My Awesome Opportunity'
      fill_in 'account_name', with: 'Example Account'
      select 'Prospecting', from: 'opportunity_stage'
      click_link 'Comment'
      fill_in 'comment_body', with: 'This is a very important opportunity.'
      click_button 'Create Opportunity'
      expect(page).to have_content('My Awesome Opportunity')

      find('div#opportunities').click_link('My Awesome Opportunity')
      expect(page).to have_content('This is a very important opportunity.')

      click_link "Dashboard"
      expect(page).to have_content("Bill Murray created opportunity My Awesome Opportunity")
      expect(page).to have_content("Bill Murray created comment on My Awesome Opportunity")
    end
  end

  scenario "remembers the comment field when the creation was unsuccessful", js: true do
    visit opportunities_page
    click_link 'Create Opportunity'
    select 'Prospecting', from: 'opportunity_stage'

    click_link 'Comment'
    fill_in 'comment_body', with: 'This is a very important opportunity.'
    click_button 'Create Opportunity'

    expect(page).to have_field('comment_body', with: 'This is a very important opportunity.')
  end

  scenario 'should view and edit an opportunity', js: true do
    create(:account, name: 'Example Account')
    create(:account, name: 'Other Example Account')
    create(:opportunity, name: 'A Cool Opportunity')
    with_versioning do
      visit opportunities_page
      click_link 'A Cool Opportunity'
      click_link 'Edit'
      fill_in 'opportunity_name', with: 'An Even Cooler Opportunity'
      select 'Other Example Account', from: 'account_id'
      select 'Analysis', from: 'opportunity_stage'
      click_button 'Save Opportunity'
      expect(page).to have_content('An Even Cooler Opportunity')
      click_link "Dashboard"
      expect(page).to have_content("Bill Murray updated opportunity An Even Cooler Opportunity")
    end
  end

  scenario 'should delete an opportunity', js: true do
    create(:opportunity, name: 'Outdated Opportunity')
    visit opportunities_page
    click_link 'Outdated Opportunity'
    click_link 'Delete?'
    expect(page).to have_content('Are you sure you want to delete this opportunity?')
    click_link 'Yes'
    expect(page).to have_content('Outdated Opportunity has been deleted.')
  end

  scenario 'should search for an opportunity', js: true do
    2.times { |i| create(:opportunity, name: "Opportunity #{i}") }
    visit opportunities_page
    expect(find('#opportunities')).to have_content("Opportunity 0")
    expect(find('#opportunities')).to have_content("Opportunity 1")
    fill_in 'query', with: "Opportunity 0"
    expect(find('#opportunities')).to have_content("Opportunity 0")
    expect(find('#opportunities')).not_to have_content("Opportunity 1")
    fill_in 'query', with: "Opportunity"
    expect(find('#opportunities')).to have_content("Opportunity 0")
    expect(find('#opportunities')).to have_content("Opportunity 1")
    fill_in 'query', with: "Non-existant opportunity"
    expect(find('#opportunities')).not_to have_content("Opportunity 0")
    expect(find('#opportunities')).not_to have_content("Opportunity 1")
  end
end
