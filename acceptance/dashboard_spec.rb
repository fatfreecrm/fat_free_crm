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
  end
end