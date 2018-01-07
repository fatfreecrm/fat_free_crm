# frozen_string_literal: true

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

    # If entity has tags, join them and wrap in parantheses
    subject = "RE: [#{@entity_type.downcase}:#{@entity.id}] #{@entity_name}"
    subject += " (#{@entity.tags.join(', ')})" if @entity.tags.any?

    mail subject: subject,
         to: user.email,
         from: from_address(@user),
         date: Time.now
  end

  private

  def from_address(user = nil)
    address = Setting.dig(:email_comment_replies, :address).presence ||
              Setting.dig(:smtp, :from).presence ||
              "noreply@fatfreecrm.com"
    address = "#{user.full_name} <#{address}>" if user && !address.match(/<.+>\z/)
    address
  end
end
