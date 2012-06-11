require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Tasks', %q{
  In order to increase keep track of things
  As a user
  I want to manage tasks
} do

  before :each do
    do_login_if_not_already(:first_name => 'Bill', :last_name => 'Murray')
  end

  scenario 'should view a list of tasks which are assigned to the logged in user' do
    4.times { |i| FactoryGirl.create(:task, :name => "Task #{i}", :user => @user) }
    visit tasks_page
    page.should have_content('Task 0')
    page.should have_content('Task 1')
    page.should have_content('Task 2')
    page.should have_content('Task 3')
    page.should have_content('Create Task')
  end

  scenario 'should create a new task', :js => true do
    visit tasks_page
    page.should have_content('Create Task')
    click_link 'Create Task'
    fill_in 'task_name', :with => 'Task I Need To Do'
    chosen_select('Tomorrow', :from => 'task_bucket')
    chosen_select('Myself', :from => 'task_assigned_to')
    chosen_select('Call', :from => 'task_category')
    click_button 'Create Task'
    page.should have_content('Task I Need To Do')

    click_link 'Dashboard'
    page.should have_content('Bill Murray created task Task I Need To Do')
  end

  scenario 'creating a task for another user', :js => true do
    FactoryGirl.create(:user, :first_name => 'Another', :last_name => 'User')
    visit tasks_page
    click_link 'Create Task'
    fill_in 'task_name', :with => 'Task For Someone Else'
    chosen_select('Tomorrow', :from => 'task_bucket')
    chosen_select('Another User', :from => 'task_assigned_to')
    chosen_select('Call', :from => 'task_category')
    click_button 'Create Task'
    page.should have_content('The task has been created and assigned to Another User')

    click_link 'Tasks'
    check_filter 'tomorrow'
    page.should_not have_content('Task For Someone Else')

    click_filter_tab('Assigned')
    check_filter 'tomorrow'
    page.should have_content('Task For Someone Else')
    page.should have_content('Another User')

    click_link 'Dashboard'
    page.should have_content('Bill Murray created task Task For Someone Else')
  end

  scenario 'should view and edit a task', :js => true do
    FactoryGirl.create(:task, :id => 42, :name => 'Example Task', :user => @user)
    visit tasks_page
    click_edit_for_task_id(42)
    fill_in 'task_name', :with => 'Updated Task'
    click_button 'Save Task'
    page.should have_content('Updated Task')
    click_link 'Task'
    page.should have_content('Updated Task')

    click_link 'Dashboard'
    page.should have_content('Bill Murray updated task Updated Task')
  end

  scenario 'should delete a task', :js => true do
    FactoryGirl.create(:task, :id => 42, :name => 'Outdated Task', :user => @user)
    visit tasks_page
    click_delete_for_task_id(42)
    click_link 'Tasks'
    page.should_not have_content('Outdated Task')
  end
end
