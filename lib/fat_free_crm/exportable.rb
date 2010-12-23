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
          extra_tables = "LEFT JOIN users u1 ON u1.id = user_id"
          extra_attributes = "*, u1.first_name AS user_first_name, u1.last_name AS user_last_name, u1.email AS user_email"

          if column_names.include?("assigned_to")
            extra_tables << " LEFT JOIN users u2 ON u2.id = assigned_to"
            extra_attributes << ", u2.first_name AS assigned_to_first_name, u2.last_name AS assigned_to_last_name, u2.email AS assigned_to_email"
          end

          if column_names.include?("completed_by")
            extra_tables << " LEFT JOIN users u3 ON u3.id = completed_by"
            extra_attributes << ", u3.first_name AS completed_by_first_name, u3.last_name AS completed_by_last_name, u3.email AS completed_by_email"
          end

          scope :export, :joins => extra_tables, :select => extra_attributes

          include InstanceMethods
          extend SingletonMethods
        end
      end
    end

    module InstanceMethods
      %w(user assigned_to completed_by).each do |person|
        define_method :"#{person}_full_name" do
          return '' unless respond_to?(:"#{person}_first_name") && respond_to?(:"#{person}_last_name") && respond_to?(:"#{person}_email")
          first_name = send("#{person}_first_name")
          last_name = send("#{person}_last_name")
          first_name.blank? || last_name.blank? ? send("#{person}_email").to_s : "#{first_name} #{last_name}"
        end
      end
    end

    module SingletonMethods
    end

  end # Exportable
end # FatFreeCRM
