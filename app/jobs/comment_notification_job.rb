# frozen_string_literal: true

class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(comment)
    return unless comment.present?

    commentable = comment.commentable
    user = comment.user

    users_to_notify = User.where(id: commentable.subscribed_users.reject { |user_id| user_id == user.id })
    users_to_notify.select(&:emailable?).each do |subscriber|
      if subscriber.subscribe_to_comment_replies?
        SubscriptionMailer.comment_notification(subscriber, comment).deliver_now
      end
    end
  end
end
