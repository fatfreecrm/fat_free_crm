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

class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :entity, :polymorphic => true

  # Each subscription must be unique
  validates_uniqueness_of :user_id, :scope => [:entity_id, :entity_type, :event_type]

  validates_inclusion_of :event_type, :in => %w( comment email view update deletion )

end
