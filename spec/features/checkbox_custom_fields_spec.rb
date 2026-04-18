# frozen_string_literal: true

require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Checkbox Custom Fields', '
  In order to store multiple values
  As a user
  I want to use checkbox custom fields
' do
  before :each do
    do_login(admin: true)
  end

  scenario 'should save and update checkbox custom fields on task', :js do
    # 1. Create a checkbox custom field for Tasks
    group = FieldGroup.find_or_create_by!(klass_name: 'Task', label: 'Checkbox Info')

    field_name = 'cf_task_checkboxes'
    field = CustomField.find_by(name: field_name)
    unless field
      field = CustomField.create!(
                field_group: group,
                label: 'Task Checkboxes',
                name: field_name,
                as: 'check_boxes',
                collection: ['Option 1', 'Option 2', 'Option 3']
              )
    end

    # 2. Create a task
    task = create(:task, name: 'Task with Checkboxes', user: @user)

    # 3. Visit the task edit page
    visit task_path(task)
    click_link 'Edit'

    expect(page).to have_css('#edit_task')

    within '#edit_task' do
      if page.has_link?("Checkbox Info")
          click_link "Checkbox Info"
      end

      check 'Option 1'
      check 'Option 3'
      click_button 'Save Task'
    end

    # 4. Verify the values are saved
    expect(page).to have_no_css('#edit_task')

    # Reload to be sure
    visit task_path(task)

    section_id = "field_group_#{group.id}_task_show"
    if page.has_css?("##{section_id}", visible: false)
      find("a[data-id='#{section_id}']").click
    end

    expect(page).to have_content('Option 1, Option 3')

    # 5. Update and uncheck some
    click_link 'Edit'
    within '#edit_task' do
      if page.has_link?("Checkbox Info")
          click_link "Checkbox Info"
      end
      uncheck 'Option 1'
      check 'Option 2'
      click_button 'Save Task'
    end

    expect(page).to have_no_css('#edit_task')
    visit task_path(task)

    if page.has_css?("##{section_id}", visible: false)
      find("a[data-id='#{section_id}']").click
    end
    expect(page).to have_content('Option 2, Option 3')
    expect(page).not_to have_content('Option 1')
  end
end
