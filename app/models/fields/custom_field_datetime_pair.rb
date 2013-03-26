# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class CustomFieldDatetimePair < CustomFieldDatePair

  # Register this CustomField with the application
  #------------------------------------------------------------------------------
  register(:as => 'datetime_pair', :klass => 'CustomFieldDatetimePair', :type => 'timestamp')

  def render(value)
    value && value.strftime(I18n.t("time.formats.mmddhhss"))
  end

end
