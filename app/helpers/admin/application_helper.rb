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

module Admin::ApplicationHelper

  def link_to_delete(model, params = {})
    name = model.class.name.underscore.downcase
    link_to_remote(t(:yes_button),
      :url => params[:url] || send("admin_#{name}_path", model),
      :method => :delete,
      :before => visual_effect(:highlight, dom_id(model), :startcolor => "#ffe4e1")
    )
  end
end
