# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
  belongs_to  :user
  belongs_to  :commentable, :polymorphic => true

  scope :created_by, lambda { |user| where(:user_id => user.id) }

  validates_presence_of :user, :commentable, :comment
  has_paper_trail :meta => { :related => :commentable },
                  :ignore => [:state]

  before_create :subscribe_mentioned_users
  after_create  :subscribe_user_to_entity, :notify_subscribers

  def expanded?;  self.state == "Expanded";  end
  def collapsed?; self.state == "Collapsed"; end

  private
  # Add user to subscribed_users field on entity
  def subscribe_user_to_entity(u = user)
    subscribed_users = (commentable.subscribed_users + [u.id]).uniq
    commentable.update_attribute :subscribed_users, subscribed_users
  end

  # Notify subscribed users when a comment is added, unless user created this comment
  def notify_subscribers
    commentable.subscribed_users.reject{|user_id| user_id == user.id}.each do |subscriber_id|
      if subscriber = User.find_by_id(subscriber_id)
        SubscriptionMailer.comment_notification(subscriber, self).deliver
      end
    end
  end

  # If a user is mentioned in the comment body, subscribe them to the entity
  # before creation, so that they are sent an email notification
  def subscribe_mentioned_users
    # Scan for usernames mentioned in the comment,
    # e.g. "Hi @example_user, take a look at this lead. Please show @another_user"
    comment.scan(/@([a-zA-Z0-9_-]+)([^a-zA-Z0-9_-]|$)/).map(&:first).each do |username|
      if (mentioned_user = User.find_by_username(username))
        subscribe_user_to_entity(mentioned_user)
      end
    end
  end
end
