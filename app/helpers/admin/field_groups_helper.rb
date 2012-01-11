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

module Admin::FieldGroupsHelper
  def field_group_subtitle(field_group)
    asset = field_group.klass_name.downcase
    html = t(field_group.name, :default => field_group.label)
    html << content_tag(:small, :id => "#{asset}_field_group_#{field_group.id}_intro") do
      if field_group.tag_id
        t(:field_group_tag_restriction, :assets => asset.pluralize, :tag => field_group.tag.name)
      else
        t(:field_group_unrestricted, :assets => asset.pluralize)
      end
    end
    html.html_safe
  end
end
