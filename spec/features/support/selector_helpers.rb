# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module SelectorHelpers
  def click_filter_tab(filter_name)
    tab = find(:xpath, "//div[@class='filters']//a[contains(text(), '#{filter_name}')]")
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

  # See github.com/goodwill/capybara-select2
  def select2(value, options = {})
    select2_container = find("div.label", text: options[:from]).find(:xpath, '..').find('.select2-container')

    select2_container.find(".select2-selection").click
    drop_container = ".select2-dropdown"
    find(:xpath, "//body").find("#{drop_container} li.select2-results__option", text: value).click
  end
end

RSpec.configuration.include SelectorHelpers, type: :feature
