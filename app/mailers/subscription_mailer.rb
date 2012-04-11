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

class SubscriptionMailer < ActionMailer::Base

  def comment_notification(user, comment)
    @entity = comment.commentable
    @entity_type = @entity.class.to_s
    @entity_name = @entity.respond_to?(:full_name) ? @entity.full_name : @entity.name

    @comment = comment
    @user = comment.user

    # If entity has tags, join them and wrap in parantheses
    subject = "RE: [#{@entity_type.downcase}:#{@entity.id}] #{@entity_name}"
    subject << " (#{@entity.tag_list.join(', ')})" if @entity.tag_list.any?

    mail :subject => subject,
         :to => user.email,
         :from => "#{@user.full_name} <#{Setting.email_comment_replies[:address]}>",
         :date => Time.now
  end
end
