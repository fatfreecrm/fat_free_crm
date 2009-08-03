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

class Admin::UsersController < Admin::ApplicationController
  before_filter :set_current_tab, :only => [ :index, :show ]

  # GET /admin/users
  # GET /admin/users.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @users = get_users

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @users }
    end
  end

  # GET /admin/users/1
  # GET /admin/users/1.xml
  #----------------------------------------------------------------------------
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @user }
    end
  end

  # GET /admin/users/new
  # GET /admin/users/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  def new
    @user = User.new

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @user }
    end
  end

  # GET /admin/users/1/edit
  #----------------------------------------------------------------------------
  def edit
    @user = User.find(params[:id])
  end

  # POST /admin/users
  # POST /admin/users.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def create
    params[:user][:password_confirmation] = nil if params[:user][:password_confirmation].blank?
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save_without_session_maintenance
        @users = get_users
        format.js   # create.js.rjs
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.xml
  #----------------------------------------------------------------------------
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(admin_users_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.xml
  #----------------------------------------------------------------------------
  def destroy
    @user = User.find(params[:id])
    flash[:notice] = 'Deleting users is not implemented yet.'
    # @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end

  private
  #----------------------------------------------------------------------------
  def get_users
    User.all(:order => "id DESC").paginate
  end

end
