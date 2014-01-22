# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module SelectorHelpers
  def chosen_select(item_text, options)
    field_id = find_field(options[:from], :visible => false)[:id]
    option_value = page.evaluate_script("$(\"##{field_id} option:contains('#{item_text}')\").val()")
    page.execute_script("$('##{field_id}').val('#{option_value}')")
  end

  def click_filter_tab(filter_name)
    tab = find(:xpath, "//div[@class='filters']//td[contains(text(), '#{filter_name}')]")
    tab.click
  end

  def click_edit_for_task_id(task_id)
    within("#task_#{task_id}") do
      page.execute_script "$('#task_#{task_id} a')[0].click()"
    end
  end

  def click_delete_for_task_id(task_id)
    within("#task_#{task_id}") do
      page.execute_script "$('#task_#{task_id} a')[1].click()"
    end
  end
end

RSpec.configuration.include SelectorHelpers, :type => :feature
