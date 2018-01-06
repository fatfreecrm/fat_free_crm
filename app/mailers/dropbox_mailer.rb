# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class DropboxMailer < ActionMailer::Base
  def dropbox_notification(user, from, email, mediator_links)
    I18n.locale = Setting.locale
    @mediator_links = mediator_links.join("\n")
    @subject        = email.subject
    @body           = email.body_plain

    mail subject: I18n.t(:dropbox_notification_subject, subject: email.subject),
         to: user.email,
         from: from,
         date: Time.now
  end
end
