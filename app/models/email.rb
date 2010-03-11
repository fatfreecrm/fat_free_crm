# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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
# Schema version: 27
#
# Table name: emails
#
#  id              :integer(4)  not null, primary key
#  imap_message_id :string      not null
#  user_id         :integer(4)
#  mediator_id     :integer(4)
#  mediator_type   :string
#  from            :string      not null
#  to              :string      not null
#  cc              :string
#  bcc             :string
#  subject         :string
#  body            :text
#  sent_at         :datetime
#  received_at     :datetime
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#
class Email < ActiveRecord::Base
  belongs_to :mediator, :polymorphic => true
  belongs_to :user
  
  acts_as_paranoid
  after_create :log_activity
  
  private
  def log_activity
    current_user = User.find(user_id)
    Activity.log(current_user, mediator, :dropboxed) if current_user
  end  
end