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

# Take into account current time zone when serializing datetime values
# See: https://rails.lighthouseapp.com/projects/8994/tickets/6096-to_xml-datetime-format-regression

ActiveModel::Serializers::Xml::Serializer::Attribute.class_eval do
  def initialize(name, serializable, raw_value=nil)
    @name, @serializable = name, serializable
    raw_value = raw_value.in_time_zone if raw_value.respond_to?(:in_time_zone)
    @value = raw_value || @serializable.send(name)
    @type  = compute_type
  end
end

