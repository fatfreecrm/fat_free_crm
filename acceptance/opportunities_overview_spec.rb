require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Opportunities Overview', %q{
  In order to keep track of my team's responsibilities
  As a user
  I want to see an overview of opportunities broken down by user
} do

  background do
    @me = FactoryGirl.create(:user)

    @user1 = FactoryGirl.create(:user, :first_name => "Brian", :last_name => 'Doyle-Murray', :id => 64)
    FactoryGirl.create(:opportunity, :name => "Acting", :stage => 'prospecting', :assignee => @user1)
    FactoryGirl.create(:opportunity, :name => "Directing", :stage => 'won', :assignee => @user1)

    @user2 = FactoryGirl.create(:user, :first_name => "Dean", :last_name => 'Stockwell', :id => 86)
    @account1 = FactoryGirl.create(:account, :name => 'Quantum Leap')
    FactoryGirl.create(:opportunity, :name => "Leaping", :stage => 'prospecting', :account => @account1, :assignee => @user2)
    FactoryGirl.create(:opportunity, :name => "Return Home", :stage => 'prospecting', :account => @account1, :assignee => @user2)

    @user3 = FactoryGirl.create(:user, :first_name => "Chris", :last_name => 'Jarvis', :id => 16)
    FactoryGirl.create(:opportunity, :stage => 'won', :assignee => @user3)
    FactoryGirl.create(:opportunity, :stage => 'lost', :assignee => @user3)

    login_as_user(@me)
  end

  scenario "Accessing Opportunity overview via the nav" do
    visit homepage
    within "#tabs" do
      click_link "Team"
    end

    current_path.should == opportunity_overview_page
  end

  scenario "Viewing opportunity overview" do
    visit opportunity_overview_page

    within "#user_64" do
      page.should have_selector('.title', :text => 'Brian Doyle-Murray')
      page.should have_content('Acting')
      page.should_not have_content('Directing')
    end

    within "#user_86" do
      page.should have_selector('.title', :text => 'Dean Stockwell')
      page.should have_content('Leaping from Quantum Leap')
      page.should have_content('Return Home from Quantum Leap')
    end

    page.should_not have_selector('#user_16')
  end
end