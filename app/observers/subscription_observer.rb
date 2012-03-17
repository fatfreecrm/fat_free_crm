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

class SubscriptionObserver < ActiveRecord::Observer
  observe :comment

  # Notify users when a comment is added to an entity that they have subscribed to
  def after_create(comment)
    Subscription.for_entity(comment.entity).
    where(:event_type => "comment").
    where(["user_id IS NOT '?'", comment.user.id]).each do |subscription|
      SubscriptionMailer.comment_notification(subscription, comment)
    end
  end

end

