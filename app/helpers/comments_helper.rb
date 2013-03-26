# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module CommentsHelper

  # Generates a list of links for the subscribed users
  def subscribed_user_links(users)
    links = users.map {|user| link_to(user.full_name, user_path(user)) }
    links.join(", ").html_safe
  end

  def notification_emails_configured?
    config = Setting.email_comment_replies || {}
    config[:server].present? && config[:user].present? && config[:password].present?
  end
end
