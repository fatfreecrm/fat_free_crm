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

class PasswordsController < ApplicationController

  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]
  before_filter :require_no_user
  
  #----------------------------------------------------------------------------
  def new
    # <-- render new.html.haml
  end
  
  #----------------------------------------------------------------------------
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = t(:msg_pwd_instructions_sent)
      redirect_to root_url
    else
      flash[:notice] = t(:msg_email_not_found)
      redirect_to :action => :new
    end
  end
  
  #----------------------------------------------------------------------------
  def edit
    # <-- render edit.html.haml
  end

  #----------------------------------------------------------------------------
  def update
    if empty_password?
      flash[:notice] = t(:msg_enter_new_password)
      render :edit
    elsif @user.update_attributes(params[:user])
      flash[:notice] = t(:msg_password_updated)
      redirect_to profile_url
    else
      render :edit
    end
  end

  #----------------------------------------------------------------------------
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = <<-EOS
        Sorry, we could not locate your user profile. Try to copy and paste the URL
        from your email into your browser or restart the reset password process.
      EOS
      redirect_to root_url
    end
  end

  #----------------------------------------------------------------------------
  def empty_password?
    (params[:user][:password] == params[:user][:password_confirmation]) &&
    (params[:user][:password] =~ /^\s*$/)
  end
end
