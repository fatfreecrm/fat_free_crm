module SelectorHelpers
  def chosen_select(item_text, options)
    field_id = find_field(options[:from])[:id]
    option_value = page.evaluate_script("jQuery(\"##{field_id} option:contains('#{item_text}')\").val()")#page.evaluate_script("$(\"##{field_id} option:contains('#{item_text}')\").val()")
    page.execute_script("jQuery('##{field_id}').val('#{option_value}')")
  end

  def check_filter(filter_name)
    filter_checkbox = find(:xpath, "//input[@type='checkbox'][@value='due_#{filter_name}']")
    filter_checkbox.click
  end

  def click_filter_tab(filter_name)
    tab = find(:xpath, "//div[@class='filters']//td[contains(text(), '#{filter_name}')]")
    tab.click
  end

  def click_edit_for_task_id(task_id)
    within("#task_#{task_id}") do
      page.execute_script "jQuery('#task_#{task_id} a')[0].click()"
    end
  end

  def click_delete_for_task_id(task_id)
    within("#task_#{task_id}") do
      page.execute_script "jQuery('#task_#{task_id} a')[1].click()"
    end
  end
end

RSpec.configuration.include SelectorHelpers, :type => :request