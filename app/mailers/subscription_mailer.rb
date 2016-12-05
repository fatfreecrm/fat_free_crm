# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

class SubscriptionMailer < ActionMailer::Base
  def comment_notification(user, comment)
    @entity = comment.commentable
    @entity_type = @entity.class.to_s
    @entity_name = @entity.respond_to?(:full_name) ? @entity.full_name : @entity.name

    @comment = comment
    @user = comment.user

    if (reply_to = Setting.email_comment_replies[:address]).blank?
      email_host = Setting.host.present? ? Setting.host : 'example.com'
      reply_to = "no-reply@#{email_host}"
    end

    # If entity has tags, join them and wrap in parantheses
    subject = "RE: [#{@entity_type.downcase}:#{@entity.id}] #{@entity_name}"
    subject << " (#{@entity.tag_list.join(', ')})" if @entity.tag_list.any?

    mail subject: subject,
         to: user.email,
         from: "#{@user.full_name} <#{reply_to}>",
         date: Time.now
  end
end
