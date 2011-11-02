# Fat Free CRM
# Copyright (C) 2008-2009 by Michael Dvorkin
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

class CustomField < Field

  delegate :table_name, :to => :field_group

  after_validation :update_column, :on => :update
  after_create     :add_column

  def label=(value)
    if name.blank? and value.present?
      self.name = 'cf_' + value.underscore.gsub(/[^a-z0-9_]/, '').gsub(/[_ ]+/, '_')
    end
    super
  end

  def add_column
    unless klass.columns.map(&:name).include?(self.name)
      connection.add_column(table_name, name, column_type)
      klass.reset_column_information
    end
  end

  def update_column
    if self.errors.empty?
      if self.name_changed?
        connection.rename_column(table_name, name_was, column_type)
        klass.reset_column_information
      end
    end
  end
end
