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

class Admin::UsersController < Admin::ApplicationController
  before_filter "set_current_tab('admin/users')", :only => [ :index, :show ]

  load_resource :except => [:create]

  # GET /admin/users
  # GET /admin/users.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @users = get_users(:page => params[:page])
    respond_with(@users)
  end

  # GET /admin/users/1
  # GET /admin/users/1.xml
  #----------------------------------------------------------------------------
  def show
    respond_with(@user)
  end

  # GET /admin/users/new
  # GET /admin/users/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  def new
    respond_with(@user)
  end

  # GET /admin/users/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = User.find_by_id($1) || $1.to_i
    end

    respond_with(@user)
  end

  # POST /admin/users
  # POST /admin/users.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def create
    params[:user][:password_confirmation] = nil if params[:user][:password_confirmation].blank?
    admin = params[:user].delete(:admin)
    @user = User.new(params[:user])
    @user.admin = (admin == "1")
    @user.save_without_session_maintenance
    @users = get_users

    respond_with(@user)
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def update
    params[:user][:password_confirmation] = nil if params[:user][:password_confirmation].blank?
    admin = params[:user].delete(:admin)
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    @user.admin = (admin == "1")
    @user.save_without_session_maintenance

    respond_with(@user)
  end

  # GET /admin/users/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  def confirm
    respond_with(@user)
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  def destroy
    unless @user.destroy
      flash[:warning] = t(:msg_cant_delete_user, @user.full_name)
    end

    respond_with(@user)
  end

  # POST /users/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  # Handled by Admin::ApplicationController :auto_complete

  # PUT /admin/users/1/suspend
  # PUT /admin/users/1/suspend.xml                                         AJAX
  #----------------------------------------------------------------------------
  def suspend
    @user.update_attribute(:suspended_at, Time.now) if @user != @current_user

    respond_with(@user)
  end

  # PUT /admin/users/1/reactivate
  # PUT /admin/users/1/reactivate.xml                                      AJAX
  #----------------------------------------------------------------------------
  def reactivate
    @user.update_attribute(:suspended_at, nil)

    respond_with(@user)
  end

private

  #----------------------------------------------------------------------------
  def get_users(options = {})
    self.current_page  = options[:page] if options[:page]
    self.current_query = params[:query] if params[:query]

    @search = klass.search(params[:q])
    @search.build_grouping unless @search.groupings.any?

    wants = request.format
    scope = User.by_id
    scope = scope.merge(@search.result)
    scope = scope.text_search(current_query)      if current_query.present?
    scope = scope.paginate(:page => current_page) if wants.html? || wants.js? || wants.xml?
    scope
  end
end
