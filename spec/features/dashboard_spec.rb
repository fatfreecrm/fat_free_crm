# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Dashboard', '
  In order to monitor activity
  As a user
  I want to see a dashboard
' do
  background do
    @me = create(:user)
    login_as_user(@me)

    create(:task, name: 'Do your homework!', assignee: @me)
    create(:opportunity, name: 'Work with the Dolphins', assignee: @me, stage: 'proposal')
    create(:account, name: 'Dolphin Manufacturer', assignee: @me)
  end

  scenario "Viewing my dashboard" do
    visit homepage

    # My Tasks
    within "#tasks" do
      expect(page).to have_content("Do your homework!")
    end

    # My Opportunities
    within "#opportunities" do
      expect(page).to have_content("Work with the Dolphins")
    end

    # My Accounts
    within "#accounts" do
      expect(page).to have_content("Dolphin Manufacturer")
    end
  end

  scenario "Only show a maximum of 10 entities" do
    10.times do
      create(:task, assignee: @me)
      create(:opportunity, assignee: @me, stage: 'proposal')
      create(:account, assignee: @me)
    end

    visit homepage

    # My Tasks
    within "#tasks" do
      expect(page).to have_content("Not showing 1 hidden task.")
    end

    # My Opportunities
    within "#opportunities" do
      expect(page).to have_content("Not showing 1 hidden opportunity.")
    end

    # My Accounts
    within "#accounts" do
      expect(page).to have_content("Not showing 1 hidden account.")
    end
  end
end
