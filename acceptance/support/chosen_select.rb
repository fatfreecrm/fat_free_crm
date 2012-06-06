module ChosenSelect
  def select_from_chosen(selector, name)
    page.execute_script "jQuery('#{selector}').click();"
    page.execute_script "jQuery(\".chzn-results .active-result:contains('#{name}')\").click();"
  end
end

RSpec.configuration.include ChosenSelect, :type => :acceptance