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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module HomeHelper
  def sort_by_assets
    Activity::ASSETS.map do |key, value|
      %Q[{ name: "#{value}", on_select: function() { #{redraw(:asset, [ key, value.downcase ], url_for(:action => :redraw))} } }]
    end
  end

  def sort_by_duration
    Activity::DURATION.map do |key, value|
      %Q[{ name: "#{value}", on_select: function() { #{redraw(:duration, [ key, value.downcase ], url_for(:action => :redraw))} } }]
    end
  end

  def sort_by_users
    users = [[ "all_users", t(:option_all_users) ]] + @all_users.map do |user|
      escaped = escape_javascript(user.full_name)
      [ escaped, escaped ]
    end

    users.map do |key, value|
      %Q[{ name: "#{value}", on_select: function() { #{redraw(:user, [ key, (value == t(:option_all_users) ? value.downcase : value) ], url_for(:action => :redraw))} } }]
    end
  end
end
