# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
#
# Configure ActionMailer unless running tests
#   ActionMailer is setup in test mode later on
#
unless Rails.env.test?

  smtp_settings = Setting.smtp || {}

  Rails.application.config.action_mailer.smtp_settings = smtp_settings.symbolize_keys if smtp_settings["address"].present?

  if (host = Setting.host).present?
    (Rails.application.routes.default_url_options ||= {})[:host] = host.gsub('http://', '')
  end

end
