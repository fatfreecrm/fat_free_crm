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

class LeadObserver < ActiveRecord::Observer
  observe :lead

  @@leads = {}

  def before_update(item)
    @@leads[item.id] = Lead.find(item.id).freeze
  end

  def after_update(item)
    original = @@leads.delete(item.id)
    if original && original.status != "rejected" && item.status == "rejected"
      return log_activity(item, :rejected)
    end
  end

  private

  def log_activity(item, event)
    item.send(self.class.versions_association_name).create {:event => event, :whodunnit => PaperTrail.whodunnit}
  end
end
