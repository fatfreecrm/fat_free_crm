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
  module Sortable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Model class method to define sort options, for example:
      #   sortable :by => "first_name ASC"
      #   sortable :by => [ "first_name ASC", "last_name ASC" ]
      #   sortable :by => [ "first_name ASC", "last_name ASC" ], :default => "last_name ASC"
      #--------------------------------------------------------------------------
      def sortable(options = {})
        cattr_accessor :sort_by,            # Default sort order with prepended table name.
                       :sort_by_fields,     # Array of fields to sort by without ASC/DESC.
                       :sort_by_clauses     # A copy of sortable :by => ... stored as array.

        self.sort_by_clauses = [options[:by]].flatten
        self.sort_by_fields = self.sort_by_clauses.map(&:split).map(&:first)
        self.sort_by = self.name.tableize + "." + (options[:default] || options[:by].first)
      end

      # Return hash that maps sort options to the actual :order strings, for example:
      #   "first_name" => "leads.first_name ASC",
      #   "last_name"  => "leads.last_name ASC"
      #--------------------------------------------------------------------------
      def sort_by_map
        Hash[
          self.sort_by_fields.zip(self.sort_by_clauses).map do |field, clause|
            [ field, self.name.tableize + "." + clause ]
          end
        ]
      end

    end # ClassMethods

  end
end