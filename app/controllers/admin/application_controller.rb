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

class Admin::ApplicationController < ApplicationController
  layout "admin/application"
  before_filter :require_admin_user

  # Autocomplete handler for all admin controllers.
  #----------------------------------------------------------------------------
  def auto_complete
    @query = params[:auto_complete_query]
    @auto_complete = self.controller_name.classify.constantize.search(@query).limit(10)
    render "common/auto_complete", :layout => nil
  end

  private
  #----------------------------------------------------------------------------
  def require_admin_user
    require_user
    if @current_user && !@current_user.admin?
      flash[:notice] = t(:msg_require_admin)
      redirect_to root_path
    end
  end
end
