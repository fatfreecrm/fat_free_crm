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
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module FatFreeCRM
  module Exportable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def exportable(options = {})
        unless included_modules.include?(InstanceMethods)
          include InstanceMethods
          extend SingletonMethods
        end
      end
    end

    module InstanceMethods
      def user_id_full_name
        user = self.user
        user ? user.full_name : ''
      end

      def self.included(base)
        if base.instance_methods.include?(:assignee)
          define_method :assigned_to_full_name do
            user = self.assignee
            user ? user.full_name : ''
          end
        end

        if base.instance_methods.include?(:completor)
          define_method :completed_by_full_name do
            user = self.completor
            user ? user.full_name : ''
          end
        end
      end
    end

    module SingletonMethods
    end

  end # Exportable
end # FatFreeCRM
