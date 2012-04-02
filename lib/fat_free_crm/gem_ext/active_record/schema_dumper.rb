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

#
# Override SchemaDumper so that it ignores custom fields when generating db/schema.rb
#
require 'active_record'

unless ENV['INCLUDE_CUSTOM_FIELDS']
  module ActiveRecord
    SchemaDumper.class_eval do
      def initialize_with_ignored_custom_fields(connection)
        # Override :columns method on this connection, to ignore any custom field columns
        connection.class_eval do
          def columns(*args)
            super.reject { |c| c.name.start_with? "cf_" }
          end
        end
        initialize_without_ignored_custom_fields(connection)
      end

      alias_method_chain :initialize, :ignored_custom_fields
    end
  end
end
