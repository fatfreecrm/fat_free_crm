# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
def fill_autocomplete(field, options = {})
  fill_in field, with: options[:with]
  page.execute_script %{ $('##{field}').trigger('focus') }
  page.execute_script %{ $('##{field}').trigger('keydown') }

  selector = %{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}
  sleep(1)
  expect(page).to have_selector('ul.ui-autocomplete li.ui-menu-item a')
  page.execute_script %{ $('#{selector}').trigger('mouseenter').click() }
end
