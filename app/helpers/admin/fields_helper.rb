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

module Admin::FieldsHelper

  # Returns the list of :null and :safe database column transitions.
  # Only these options should be shown on the custom field edit form.
  def field_edit_as_options(field = nil)
    # Return every available field_type if no restriction
    options = (field.as.present? ? field.available_as : Field.field_types).keys
    options.map{|k| [t("field_types.#{k}.title"), k] }
  end

  def field_group_options
    FieldGroup.all.map {|fg| [fg.name, fg.id]}
  end
end
