module FormNavigationHelpers
  def click_submit_and_await_form_transition(button_text, form_selector, wait = 5)
    button_element = find(form_selector, wait: 0.1)

    find(form_selector).click_button(button_text)
    
    orig_time = Time.now
    while still_visible?(button_element)
      now_time = Time.now
      raise "Form did not transition" if (now_time - orig_time > wait)
      sleep 0.2
      button_element.reload
    end
  end

  def still_visible?(element)
    element.visible? rescue false
  end

  def click_submit_and_fail_form_transition(button_text, form_selector, wait = 5)
    find(form_selector).click_button(button_text)

    button_element = find(form_selector).all(:button, text: button_text, disabled: true, wait: 0.1)
    orig_time = Time.now
    while button_element.any?
      now_time = Time.now
      raise "Form did not transition" if (now_time - orig_time > wait)
      sleep 0.2
      button_element = find(form_selector).all(:button, text: button_text, disabled: true, wait: 0.1)
    end
  end

  def visit_dashboard(wait = 5)
    click_link 'Dashboard'
    active_dash_element = all(".nav-link.active", text: 'Dashboard')
    orig_time = Time.now
    while active_dash_element.empty?
      now_time = Time.now
      raise "Dashboard did not load" if (now_time - orig_time > wait)
      sleep 0.2
      active_dash_element = all(".nav-link.active", text: 'Dashboard')
    end
  end

  def click_link_and_await_form_load(link_text, form_selector, wait = 5)
    click_link link_text
    form_element = all(form_selector)
    orig_time = Time.now
    while form_element.empty?
      now_time = Time.now
      raise "Form did not load" if (now_time - orig_time > wait)
      sleep 0.2
      form_element = all(form_selector)
    end
  end
end

RSpec.configuration.include FormNavigationHelpers, type: :feature