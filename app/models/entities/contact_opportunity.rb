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
# Table name: contact_opportunities
#
#  id             :integer         not null, primary key
#  contact_id     :integer
#  opportunity_id :integer
#  role           :string(32)
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class ContactOpportunity < ActiveRecord::Base
  belongs_to :contact
  belongs_to :opportunity
  validates_presence_of :contact_id, :opportunity_id

  # has_paper_trail
end
