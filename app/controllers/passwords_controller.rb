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

class PasswordsController < ApplicationController

  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]
  before_filter :require_no_user
  
  #----------------------------------------------------------------------------
  def new
    render
  end
  
  #----------------------------------------------------------------------------
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to home_url
    else
      flash[:notice] = "No user was found with that email address."
      render :action => :new
    end
  end
  
  #----------------------------------------------------------------------------
  def edit
    render
  end

  #----------------------------------------------------------------------------
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password was successfully updated."
      redirect_to profile_url
    else
      render :action => :edit
    end
  end

  #----------------------------------------------------------------------------
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = <<-EOS
        We are sorry, but we could not locate your user profile. If you are having 
        issues try copying and pasting the URL from your email into your browser
        or restarting the reset password process.
      EOS
      redirect_to home_url
    end
  end

end
