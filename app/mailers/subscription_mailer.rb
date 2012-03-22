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
    @entity_tags = @entity.tag_list.any? ? "(#{@entity.tag_list.join(', ')})" : ""
    @comment = comment

    mail :subject => I18n.t('comment_notification.subject',
                            :entity => @entity.class.to_s.downcase,
                            :id     => @entity.id,
                            :name   => @entity.full_name,
                            :tags   => @entity_tags),
         :to => user.email,
         :from => "FFCRM Comments <#{Setting.email_comment_inbox[:address]}>",
         :date => Time.now
  end

  # Processes received messages and adds comment to the associated entity
  def self.new_comment(message, entity_name, entity_id)
    # Check that entity is a known model
    if %w(account campaign contact lead opportunity task).include?(entity_name)
      # Find entity from class & id
      if entity = entity_name.capitalize.constantize.find_by_id(entity_id)
        if user = User.find_by_email(message.from.first)
          Comment.create :user        => user,
                         :commentable => entity,
                         :comment     => message.body.decoded
        end
      end
    end
  end

end
