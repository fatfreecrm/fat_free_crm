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

