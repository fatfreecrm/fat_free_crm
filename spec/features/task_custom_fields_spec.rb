# frozen_string_literal: true

require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Task Custom Fields', '
  In order to see more information about tasks
  As a user
  I want to see custom fields on the task show page
' do
  before :each do
    do_login(admin: true)
  end

  scenario 'should display custom fields on task show page', :js do
    # 1. Create a custom field for Tasks
    group = FieldGroup.find_or_create_by!(klass_name: 'Task', label: 'More Task Info')

    field_name = 'cf_task_test_field'
    field = CustomField.find_by(name: field_name)
    unless field
      # If column exists but field record doesn't (from previous interrupted runs),
      # we handle it to avoid duplicate column error.
      if Task.column_names.include?(field_name)
         # Manually insert into the fields table to skip callbacks
         ActiveRecord::Base.connection.execute("INSERT INTO fields (type, field_group_id, name, label, \"as\", created_at, updated_at) VALUES ('CustomField', #{group.id}, '#{field_name}', 'Test Field', 'string', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)")
         field = CustomField.find_by(name: field_name)
      else
        field = CustomField.create!(
                  field_group: group,
                  label: 'Test Field',
                  name: field_name,
                  as: 'string'
                )
      end
    end

    # 2. Create a task with a value for the custom field
    task = create(:task, name: 'Task with Custom Field', user: @user)
    task.update_attribute(field_name.to_sym, 'Custom Value')

    # 3. Visit the task show page
    visit task_path(task)

    # 4. Verify the custom field value is visible in the MAIN panel
    expect(page).to have_content('Task with Custom Field')

    # Check that it's in the main panel
    expect(page).to have_css('.show_fields')

    # Expand the section if it is collapsed
    section_id = "field_group_#{group.id}_task_show"
    if page.has_css?("##{section_id}", visible: false)
      find("a[data-id='#{section_id}']").click
    end

    expect(page).to have_content('Test Field')
    expect(page).to have_content('Custom Value')
  end
end
