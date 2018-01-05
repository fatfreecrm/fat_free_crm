# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class CustomFieldDatetimePair < CustomFieldDatePair
  def render(value)
    value&.strftime(I18n.t("time.formats.mmddhhss"))
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_datetime_pair, self)
end
