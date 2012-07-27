require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Permissions', %q{
  In order to restrict access
  As a user
  I want to manage permissions on entities
} do

  before :each do
    do_login_if_not_already(:id => 42, :first_name => 'Bill', :last_name => 'Murray')
  end

  scenario 'should be able to view a Public entity' do
    FactoryGirl.create(:contact, :first_name => "Viewable", :last_name => "Contact")
    visit contacts_page
    within "#contacts" do
      page.should have_content('Viewable Contact')
    end
  end

  scenario 'should still be able to view an entity if changing to Private and being assigned to it', :js => true do
    FactoryGirl.create(:contact, :first_name => "Private", :last_name => "Contact", :assigned_to => 42, :user => FactoryGirl.create(:user))
    visit contacts_page
    page.should have_content('Private Contact')
    click_link('Private Contact')
    click_link('Edit')
    click_link('Permissions')
    choose('Keep it private, do not share with others')
    click_button('Save Contact')
    click_link('Contacts')
    within "#contacts" do
      page.should have_content('Private Contact')
    end
  end

  scenario 'should not be able to view an entity if changing to Private and not being assigned to it', :js => true do
    FactoryGirl.create(:user, :first_name => "Another", :last_name => "User")
    FactoryGirl.create(:contact, :first_name => "Super", :last_name => "Private", :assigned_to => 42, :user => FactoryGirl.create(:user))
    visit contacts_page
    page.should have_content('Super Private')
    click_link('Super Private')
    click_link('Edit')
    chosen_select('Another User', :from => 'contact_assigned_to')
    click_link('Permissions')
    choose('Keep it private, do not share with others')
    click_button('Save Contact')
    click_link('Contacts')
    within "#contacts" do
      page.should_not have_content('Super Private')
    end
  end

  scenario 'should always be able to view a Private entity if owning it, regardless of who it is assigned to', :js => true do
    FactoryGirl.create(:user, :first_name => "Another", :last_name => "User")
    FactoryGirl.create(:contact, :first_name => "My", :last_name => "Contact", :assigned_to => FactoryGirl.create(:user), :user => User.find(42))
    visit contacts_page
    page.should have_content('My Contact')
    click_link('My Contact')
    click_link('Edit')
    save_and_open_page
    chosen_select('Another User', :from => 'contact_assigned_to')
    click_link('Permissions')
    choose('Keep it private, do not share with others')
    click_button('Save Contact')
    click_link('Contacts')
    within "#contacts" do
      page.should have_content('My Contact')
    end
  end
end