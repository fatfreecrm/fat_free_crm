# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCrm
module CommentsHelper
  def notification_emails_configured?
    config = Setting.email_comment_replies || {}
    config[:server].present? && config[:user].present? && config[:password].present?
  end
end
end
