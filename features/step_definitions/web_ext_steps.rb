Then /^I move the mouse over "([^\"]*)"$/ do |label|
  begin
    Capybara.current_session.driver.browser.execute_script("$('#{label}').onmouseover();")
  rescue Capybara::NotSupportedByDriverError
  end
end
