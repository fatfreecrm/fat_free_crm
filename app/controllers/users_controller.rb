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

class UsersController < ApplicationController

  before_filter :require_no_user, :only => [ :new, :create ]
  before_filter :require_user, :only => [ :show ]
  before_filter :require_and_assign_user, :except => [ :new, :create, :show ]

  # GET /users
  # GET /users.xml                              HTML (not directly exposed yet)
  #----------------------------------------------------------------------------
  def index
    # not exposed
  end

  # GET /users/1
  # GET /users/1.xml                                                       HTML
  #----------------------------------------------------------------------------
  def show
    @user = params[:id] ? User.find(params[:id]) : @current_user

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml                                                     HTML
  #----------------------------------------------------------------------------
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.haml <-- signup form
      format.xml  { render :xml => @user }
    end
  end
  
  # GET /users/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    # <-- render edit.js.rjs
  end
  
  # POST /users
  # POST /users.xml                                                        AJAX
  #----------------------------------------------------------------------------
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Successfull signup, welcome to Fat Free CRM!"
      redirect_back_or_default profile_url
    else
      render :action => :new
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.js
        format.xml { head :ok }
      else
        format.js
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml                HTML and AJAX (not directly exposed yet)
  #----------------------------------------------------------------------------
  def destroy
    # not exposed
  end

  # GET /users/1/avatar
  # GET /users/1/avatar.xml                                                AJAX
  #----------------------------------------------------------------------------
  def avatar
    # <-- render avatar.js.rjs
  end

  # PUT /users/1/upload_avatar
  # PUT /users/1/upload_avatar.xml                                         AJAX
  #----------------------------------------------------------------------------
  def upload_avatar
    if params[:gravatar]
      @user.avatar = nil
      @user.save
      render
    else
      if params[:avatar]
        @user.avatar = Avatar.new(params[:avatar].merge(:entity => @user))
        unless @user.save && @user.avatar.errors.blank?
          @user.avatar.errors.clear
          @user.avatar.errors.add(:image, "^Could't upload or resize the image file you specified.")
        end
      end
      responds_to_parent { render }
    end
  end

  # GET /users/1/password
  # GET /users/1/password.xml                                              AJAX
  #----------------------------------------------------------------------------
  def password
    # <-- render password.js.rjs
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.xml                                       AJAX
  #----------------------------------------------------------------------------
  def change_password
    if @user.valid_password?(params[:current_password], true)
      unless params[:user][:password].blank?
        @user.update_attributes(params[:user])
        flash[:notice] = "Your password has been changed."
      else
        flash[:notice] = "Your password hasn't been changed."
      end
    else
      @user.errors.add(:current_password, "^Please specify valid current password")
    end
    # <-- render change_password.js.rjs
  end

  private
  #----------------------------------------------------------------------------
  def require_and_assign_user
    require_user
    @user = @current_user
  end

end
