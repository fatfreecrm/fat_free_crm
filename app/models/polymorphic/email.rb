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
# Table name: emails
#
#  id              :integer         not null, primary key
#  imap_message_id :string(255)     not null
#  user_id         :integer
#  mediator_id     :integer
#  mediator_type   :string(255)
#  sent_from       :string(255)     not null
#  sent_to         :string(255)     not null
#  cc              :string(255)
#  bcc             :string(255)
#  subject         :string(255)
#  body            :text
#  header          :text
#  sent_at         :datetime
#  received_at     :datetime
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  state           :string(16)      default("Expanded"), not null
#

class Email < ActiveRecord::Base
  belongs_to :mediator, :polymorphic => true
  belongs_to :user

  has_paper_trail :meta => { :related => :mediator },
                  :ignore => [:state]

  def expanded?;  self.state == "Expanded";  end
  def collapsed?; self.state == "Collapsed"; end

  def body; super; end

  def body_with_textile
    if defined?(RedCloth)
      RedCloth.new(body_without_textile).to_html.html_safe
    else
      body_without_textile.to_s.gsub("\n", "<br/>").html_safe
    end
  end
  alias_method_chain :body, :textile
end
