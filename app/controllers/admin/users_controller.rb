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

  # GET /admin/users
  # GET /admin/users.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @users = get_users(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @users }
      format.xls  { send_data @users.to_xls, :type => :xls }
      format.csv  { send_data @users.to_csv, :type => :csv }
      format.rss  { render "common/index.rss.builder" }
      format.atom { render "common/index.atom.builder" }
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

  # GET /admin/users/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  def edit
    @user = User.find(params[:id])

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = User.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @user
  end

  # POST /admin/users
  # POST /admin/users.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def create
    params[:user][:password_confirmation] = nil if params[:user][:password_confirmation].blank?
    @user = User.new(params[:user])
    @user.admin = (params[:user][:admin] == "1")

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
  # PUT /admin/users/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def update
    params[:user][:password_confirmation] = nil if params[:user][:password_confirmation].blank?
    @user = User.find(params[:id])
    @user.admin = (params[:user][:admin] == "1")

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.js   # update.js.rjs
        format.xml  { head :ok }
      else
        format.js   # update.js.rjs
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # GET /admin/users/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  def confirm
    @user = User.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  def destroy
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.destroy
        format.js   # destroy.js.rjs
        format.xml  { head :ok }
      else
        flash[:warning] = t(:msg_cant_delete_user, @user.full_name)
        format.js   # destroy.js.rjs
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /users/search/query                                                AJAX
  #----------------------------------------------------------------------------
  def search
    @users = get_users(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :index }
      format.xml  { render :xml => @users.to_xml }
    end
  end

  # POST /users/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  # Handled by Admin::ApplicationController :auto_complete

  # PUT /admin/users/1/suspend
  # PUT /admin/users/1/suspend.xml                                         AJAX
  #----------------------------------------------------------------------------
  def suspend
    @user = User.find(params[:id])
    @user.update_attribute(:suspended_at, Time.now) if @user != @current_user

    respond_to do |format|
      format.js   # suspend.js.rjs
      format.xml  { render :xml => @user }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # PUT /admin/users/1/reactivate
  # PUT /admin/users/1/reactivate.xml                                      AJAX
  #----------------------------------------------------------------------------
  def reactivate
    @user = User.find(params[:id])
    @user.update_attribute(:suspended_at, nil)

    respond_to do |format|
      format.js   # reactivate.js.rjs
      format.xml  { render :xml => @user }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end


  private
  #----------------------------------------------------------------------------
  def get_users(options = {})
    self.current_page  = options[:page]  if options[:page]
    self.current_query = options[:query] if options[:query]

    wants = request.format
    scope = User.by_id
    scope = scope.search(current_query)           unless current_query.blank?
    scope = scope.unscoped                        if wants.csv?
    scope = scope.paginate(:page => current_page) if wants.html? || wants.js? || wants.xml?
    scope
  end
end
