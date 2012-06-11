require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Dashboard', %q{
  In order to monitor activity
  As a user
  I want to see a dashboard
} do

  background do
    @me = FactoryGirl.create(:user)
    login_as_user(@me)

    FactoryGirl.create(:task, :name => 'Do your homework!', :assignee => @me)
    FactoryGirl.create(:opportunity, :name => 'Work with the Dolphins', :assignee => @me)
    FactoryGirl.create(:account, :name => 'Dolphin Manufacturer', :assignee => @me)
  end

  scenario "Viewing my dashboard" do
    visit homepage

    #My Tasks
    within "#tasks" do
      page.should have_content("Do your homework!")
    end

    #My Opportunities
    within "#opportunities" do
      page.should have_content("Work with the Dolphins")
    end

    #My Accounts
    within "#accounts" do
      page.should have_content("Dolphin Manufacturer")
    end
  end

  scenario "Only show a maximum of 10 entities" do
    10.times do
      FactoryGirl.create(:task, :assignee => @me)
      FactoryGirl.create(:opportunity, :assignee => @me)
      FactoryGirl.create(:account, :assignee => @me)
    end

    visit homepage

    #My Tasks
    within "#tasks" do
      page.should have_content("Not showing 1 hidden task.")
    end

    #My Opportunities
    within "#opportunities" do
      page.should have_content("Not showing 1 hidden opportunity.")
    end

    #My Accounts
    within "#accounts" do
      page.should have_content("Not showing 1 hidden account.")
    end

  end
end
