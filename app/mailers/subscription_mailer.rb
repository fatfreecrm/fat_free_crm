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

  def comment_notification(subscription, comment)
    #TODO Create a hash so that users can reply from their email inbox.
    from = "Fat Free CRM <noreply@fatfreecrm.com>"
    
    @entity = subscription.entity
    @entity_tags = @entity.tag_list.any? ? "(#{@entity.tag_list.join(', ')})" : nil
    @comment = comment
    
    mail(:subject => I18n.t('subscription:comment_notification:subject',
                       :entity_type => @entity.class.to_s,
                       :entity_name => @entity.full_name,
                       :entity_tags => @entity_tags
                     ),
         :to => subscription.user.email,
         :from => from,
         :date => Time.now)
  end
 
end
