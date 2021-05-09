# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Campaigns', '
  In order to increase customer satisfaction
  As a user
  I want to manage campaigns
' do
  before :each do
    do_login_if_not_already(first_name: 'Bill', last_name: 'Murray')
  end

  scenario 'should view a list of campaigns' do
    3.times { |i| create(:campaign, name: "Campaign #{i}") }
    visit campaigns_page
    expect(page).to have_content('Campaign 0')
    expect(page).to have_content('Campaign 1')
    expect(page).to have_content('Campaign 2')
    expect(page).to have_content('Create Campaign')
  end

  scenario 'should create a campaign', js: true do
    with_versioning do
      visit campaigns_page
      click_link 'Create Campaign'
      expect(page).to have_selector('#campaign_name', visible: true)
      fill_in 'campaign_name', with: 'Cool Campaign'
      select2 'On Hold', from: 'Status:'
      click_link 'Comment'
      fill_in 'comment_body', with: 'This campaign is very important'
      click_button 'Create Campaign'

      expect(page).to have_content('Cool Campaign')
      expect(page).to have_content('On Hold')

      find('div#campaigns').click_link 'Cool Campaign'
      expect(page).to have_content('This campaign is very important')

      click_link "Dashboard"
      expect(page).to have_content("Bill Murray created campaign Cool Campaign")
      expect(page).to have_content("Bill Murray created comment on Cool Campaign")
    end
  end

  scenario "remembers the comment field when the creation was unsuccessful", js: true do
    visit campaigns_page
    click_link 'Create Campaign'

    click_link 'Comment'
    fill_in 'comment_body', with: 'This campaign is very important'
    click_button 'Create Campaign'

    expect(find('#comment_body')).to have_content('This campaign is very important')
  end

  scenario 'should view and edit a campaign', js: true do
    create(:campaign, name: "My Cool Campaign")
    with_versioning do
      visit campaigns_page
      click_link 'My Cool Campaign'
      click_link 'Edit'
      fill_in 'campaign_name', with: 'My Even Cooler Campaign'
      select2 'Started', from: 'Status:'
      click_button 'Save Campaign'
      expect(page).to have_content('My Even Cooler Campaign')
      expect(page).to have_content('My Even Cooler Campaign')
      click_link 'Dashboard'
      expect(page).to have_content("Bill Murray updated campaign My Even Cooler Campaign")
    end
  end

  scenario 'should delete a campaign', js: true do
    create(:campaign, name: "Old Campaign")
    visit campaigns_page
    click_link 'Old Campaign'
    click_link 'Delete?'
    expect(page).to have_content('Are you sure you want to delete this campaign?')
    click_link 'Yes'
    expect(page).to have_content('Old Campaign has been deleted.')
    expect(find('div#campaigns')).not_to have_content('Old Campaign')
  end

  scenario 'should search for a campaign', js: true do
    2.times { |i| create(:campaign, name: "Campaign #{i}") }
    visit campaigns_page
    expect(find('#campaigns')).to have_content("Campaign 0")
    expect(find('#campaigns')).to have_content("Campaign 1")
    fill_in 'query', with: "Campaign 0"
    expect(find('#campaigns')).to have_content("Campaign 0")
    expect(find('#campaigns')).not_to have_content("Campaign 1")
    fill_in 'query', with: "Campaign"
    expect(find('#campaigns')).to have_content("Campaign 0")
    expect(find('#campaigns')).to have_content("Campaign 1")
    fill_in 'query', with: "False"
    expect(find('#campaigns')).not_to have_content("Campaign 0")
    expect(find('#campaigns')).not_to have_content("Campaign 1")
  end
end
