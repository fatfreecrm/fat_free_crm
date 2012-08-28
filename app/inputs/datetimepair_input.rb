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

class DatetimepairInput < DatepairInput

  private
  
  # Tell datepicker this is a datetime
  #------------------------------------------------------------------------------
  def input_html_classes
    classes = super.dup
    classes.delete('date')
    classes.push('datetime')
  end
  
  # Return value recognised by datepicker and ensure timezone properly set by AR
  #------------------------------------------------------------------------------
  def value(field)
    val = object.send(field.name)
    val.present? ? val.strftime('%Y-%m-%d %H:%M') : nil
  end

end
