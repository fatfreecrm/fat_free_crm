# frozen_string_literal: true

require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Task Show Page Edit', '
  In order to update task details
  As a user
  I want to edit a task from its show page
' do
  before :each do
    do_login_if_not_already(first_name: 'Bill', last_name: 'Murray')
  end

  scenario 'should edit a task from show page', :js do
    task = create(:task, name: 'Original Task', user: @user)
    visit task_path(task)

    expect(page).to have_content('Original Task')

    click_link 'Edit'

    expect(page).to have_css('#edit_task')
    fill_in 'task_name', with: 'Updated Task Name'
    click_button 'Save Task'

    expect(page).to have_content('Updated Task Name')
    expect(page).to have_no_css('#edit_task')
  end
end
