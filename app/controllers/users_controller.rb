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
  before_filter :require_user, :except => [ :new, :create ]

  #----------------------------------------------------------------------------
  def index
  end

  #----------------------------------------------------------------------------
  def new
    @user = User.new
  end
  
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
  
  #----------------------------------------------------------------------------
  def show
    @user = params[:id] ? User.find(params[:id]) : @current_user
  end

  #----------------------------------------------------------------------------
  def edit
    @user = @current_user
  end
  
  #----------------------------------------------------------------------------
  def update
    @user = @current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your user profile has been updated."
      redirect_to profile_url
    else
      render :action => :edit
    end
  end

end
