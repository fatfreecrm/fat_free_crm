# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Opportunities Overview', "
  In order to keep track of my team's responsibilities
  As a user
  I want to see an overview of opportunities broken down by user
" do
  background do
    @me = create(:user)

    login_as_user(@me)
  end

  scenario "Accessing Opportunity Overview via the nav" do
    visit homepage
    within ".tabs" do
      click_link "Team"
    end

    expect(current_path).to eq(opportunity_overview_page)
  end

  scenario "Viewing Opportunity Overview when all opportunities have been assigned" do
    user1 = create(:user, first_name: "Brian", last_name: 'Doyle-Murray')
    create(:opportunity, name: "Acting", stage: 'prospecting', assignee: user1)
    create(:opportunity, name: "Directing", stage: 'won', assignee: user1)

    user2 = create(:user, first_name: "Dean", last_name: 'Stockwell')
    account1 = create(:account, name: 'Quantum Leap')
    create(:opportunity, name: "Leaping", stage: 'prospecting', account: account1, assignee: user2)
    create(:opportunity, name: "Return Home", stage: 'prospecting', account: account1, assignee: user2)

    user3 = create(:user, first_name: "Chris", last_name: 'Jarvis')
    create(:opportunity, stage: 'won', assignee: user3)
    create(:opportunity, stage: 'lost', assignee: user3)

    visit opportunity_overview_page

    within "#user_#{user1.id}" do
      expect(page).to have_selector('.title', text: 'Brian Doyle-Murray')
      expect(page).to have_content('Acting')
      expect(page).not_to have_content('Directing')
    end

    within "#user_#{user2.id}" do
      expect(page).to have_selector('.title', text: 'Dean Stockwell')
      expect(page).to have_content('Leaping from Quantum Leap')
      expect(page).to have_content('Return Home from Quantum Leap')
    end

    expect(page).not_to have_selector("#user_#{user3.id}")

    expect(page).not_to have_selector('#unassigned')
  end

  scenario "Viewing Opportunity Overview when all opportunities are unassigned" do
    create(:opportunity, name: "Acting", stage: 'prospecting', assignee: nil)
    create(:opportunity, name: "Presenting", stage: 'won', assignee: nil)

    visit opportunity_overview_page

    within "#unassigned" do
      expect(page).to have_selector('.title', text: 'Unassigned Opportunities')
      expect(page).to have_content('Acting')
      expect(page).not_to have_content('Presenting')
    end
  end

  scenario "Viewing Opportunity Overview when there are no opportunities in the pipeline" do
    create(:opportunity, name: "Presenting", stage: 'lost', assignee: create(:user))
    create(:opportunity, name: "Eating", stage: 'won', assignee: nil)

    visit opportunity_overview_page

    expect(page).to have_content('There are currently no outstanding opportunities.')
    within "#main" do
      expect(page).not_to have_content("Presenting")
      expect(page).not_to have_content("Eating")
    end
  end
end
