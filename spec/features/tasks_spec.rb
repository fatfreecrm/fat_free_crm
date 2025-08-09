# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Tasks', '
  In order to increase keep track of things
  As a user
  I want to manage tasks
' do
  before :each do
    do_login_if_not_already(first_name: 'Bill', last_name: 'Murray')
  end

  scenario 'should view a list of tasks which are assigned to the logged in user' do
    4.times { |i| create(:task, name: "Task #{i}", user: @user) }
    visit tasks_page
    expect(page).to have_content('Task 0')
    expect(page).to have_content('Task 1')
    expect(page).to have_content('Task 2')
    expect(page).to have_content('Task 3')
    expect(page).to have_content('Create Task')
  end

  scenario 'should create a new task', js: true do
    with_versioning do
      visit tasks_page
      expect(page).to have_content('Create Task')
      click_link 'Create Task'
      expect(page).to have_selector('#task_name', visible: true)
      fill_in 'task_name', with: 'Task I Need To Do'
      select2 'Tomorrow', from: 'Due:'
      select2 'Myself', from: 'Assign to:'
      select2 'Call', from: 'Category:'
      click_button 'Create Task'
      expect(page).to have_content('Task I Need To Do')

      click_link 'Dashboard'
      expect(page).to have_content('Bill Murray created task Task I Need To Do')
    end
  end

  scenario 'creating a task for another user', js: true do
    create(:user, first_name: 'Another', last_name: 'User')
    with_versioning do
      visit tasks_page
      click_link 'Create Task'
      expect(page).to have_selector('#task_name', visible: true)
      fill_in 'task_name', with: 'Task For Someone Else'
      select2 'Tomorrow', from: 'Due:'
      select2 'Another User', from: 'Assign to:'
      select2 'Call', from: 'Category:'
      click_button 'Create Task'
      expect(page).to have_content('The task has been created and assigned to Another User')

      click_link 'Tasks'
      page.uncheck('filters_due_tomorrow')
      expect(page).not_to have_content('Task For Someone Else')

      click_filter_tab('Assigned')
      page.check('filters_due_tomorrow')
      expect(find('#main')).to have_content('Task For Someone Else')
      expect(find('#main')).to have_content('Another User')

      click_link 'Dashboard'
      expect(page).to have_content('Bill Murray created task Task For Someone Else')
    end
  end

  scenario 'should view and edit a task', js: true do
    create(:task, id: 42, name: 'Example Task', user: @user)
    with_versioning do
      visit tasks_page
      click_edit_for_task_id(42)
      fill_in 'task_name', with: 'Updated Task'
      click_button 'Save Task'
      expect(page).to have_content('Updated Task')
      click_link 'Dashboard'
      expect(page).to have_content('Bill Murray updated task Updated Task')
    end
  end

  scenario 'should delete a task', js: true do
    create(:task, id: 42, name: 'Outdated Task', user: @user)
    visit tasks_page
    click_delete_for_task_id(42)
    click_link 'Tasks'
    expect(page).not_to have_content('Outdated Task')
  end
end
