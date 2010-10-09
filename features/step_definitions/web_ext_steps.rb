Then /^I move the mouse over "([^\"]*)"$/ do |id|
  begin
    Capybara.current_session.driver.browser.execute_script("$('#{id}').onmouseover();")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I fire the "([^"]*)" event on "([^"]*)"$/ do |event, id|
  begin
    Capybara.current_session.driver.browser.execute_script("$('#{id}').simulate('#{event}');")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I fire the "([^"]*)" event on css selector "([^"]*)"(?:\[([\d]*)\])?$/ do |event, selector, index|
  index ||= 0
  begin
    Capybara.current_session.driver.browser.execute_script("$$('#{selector}')[#{index}].simulate('#{event}');")
  rescue Capybara::NotSupportedByDriverError
  end
end

When /^(?:|I )go with search params to (.+):$/ do |page_name, params|
  params = params.rows_hash.inject({}) do |h,(k,v)|
    h[k] = v.include?(',') ? v.split(/[,\s]+/) : v
    h
  end
  visit path_to(page_name, params.merge(:format => :json))
end
