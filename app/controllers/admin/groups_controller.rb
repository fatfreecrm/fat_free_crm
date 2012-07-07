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

class Admin::GroupsController < Admin::ApplicationController
  before_filter "set_current_tab('admin/groups')", :only => [ :index, :show ]

  load_resource

  # GET /groups
  #----------------------------------------------------------------------------
  def index
    @groups = @groups.unscoped.paginate(:page => params[:page])
  end

  # GET /groups/1
  #----------------------------------------------------------------------------
  def show
    respond_with(@group)
  end

  # GET /groups/new
  #----------------------------------------------------------------------------
  def new
    respond_with(@group)
  end

  # GET /groups/1/edit
  #----------------------------------------------------------------------------
  def edit
    respond_with(@group)
  end

  # POST /groups
  #----------------------------------------------------------------------------
  def create
    @group.update_attributes(params[:group])

    respond_with(@group)
  end

  # PUT /groups/1
  #----------------------------------------------------------------------------
  def update
    @group.update_attributes(params[:group])

    respond_with(@group)
  end

  # DELETE /groups/1
  #----------------------------------------------------------------------------
  def destroy
    @group.destroy

    respond_with(@group)
  end
end
