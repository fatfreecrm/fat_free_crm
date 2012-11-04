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

class DateTimeInput < SimpleForm::Inputs::DateTimeInput

  def input
    add_autocomplete!
    input_html_options.merge(input_options)
    @builder.text_field(attribute_name, input_html_options)
  end

  def label_target
    attribute_name
  end

  private

  def has_required?
    options[:required]
  end

  def add_autocomplete!
    input_html_options[:autocomplete] ||= 'off'
  end
end
