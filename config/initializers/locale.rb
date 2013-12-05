# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

# Set default locale from Settings
# defer setting the locale until all I18n locales have been initialized
#------------------------------------------------------------------------------
I18n.config.enforce_available_locales = true

FatFreeCRM.application.config.after_initialize do
  I18n.default_locale = Setting.locale
end
