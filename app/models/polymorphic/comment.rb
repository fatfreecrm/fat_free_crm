# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: comments
#
#  id               :integer         not null, primary key
#  user_id          :integer
#  commentable_id   :integer
#  commentable_type :string(255)
#  private          :boolean
#  title            :string(255)     default("")
#  comment          :text
#  created_at       :datetime
#  updated_at       :datetime
#  state            :string(16)      default("Expanded"), not null
#

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  scope :created_by, ->(user) { where(user_id: user.id) }

  validates_presence_of :user, :commentable, :comment
  has_paper_trail class_name: 'Version', meta: { related: :commentable },
                  ignore: [:state]

  before_create :subscribe_mentioned_users
  after_create :subscribe_user_to_entity, :notify_subscribers

  def expanded?
    state == "Expanded"
  end

  def collapsed?
    state == "Collapsed"
  end

  private

  # Add user to subscribed_users field on entity
  def subscribe_user_to_entity(u = user)
    commentable.subscribed_users << u.id
    commentable.save
  end

  # Notify subscribed users when a comment is added, unless user created this comment
  def notify_subscribers
    commentable.subscribed_users.reject { |user_id| user_id == user.id }.each do |subscriber_id|
      if subscriber = User.find_by_id(subscriber_id)
        SubscriptionMailer.comment_notification(subscriber, self).deliver_now
      end
    end
  end

  # If a user is mentioned in the comment body, subscribe them to the entity
  # before creation, so that they are sent an email notification
  def subscribe_mentioned_users
    # Scan for usernames mentioned in the comment,
    # e.g. "Hi @example_user, take a look at this lead. Please show @another_user"
    comment.scan(/@([a-zA-Z0-9_-]+)/).map(&:first).each do |username|
      if (mentioned_user = User.find_by_username(username))
        subscribe_user_to_entity(mentioned_user)
      end
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_comment, self)
end
