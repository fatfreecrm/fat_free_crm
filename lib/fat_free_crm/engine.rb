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

module FatFreeCRM
  class Engine < ::Rails::Engine
    config.autoload_paths += Dir[root.join("app/models/**")] +
                             Dir[root.join("app/controllers/entities")]

    config.to_prepare do
      ActiveRecord::Base.observers = :lead_observer, :opportunity_observer, :task_observer, :mailchimp_observer, :saasu_observer
    end
  end
end
