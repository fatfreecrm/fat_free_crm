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

class AuthenticationsController < ApplicationController

  before_filter :require_no_user, :only => [ :new, :create ]
  before_filter :require_user, :only => :destroy
  
  #----------------------------------------------------------------------------
  def new
    @authentication = Authentication.new
  end
  
  #----------------------------------------------------------------------------
  def create
    @authentication = Authentication.new(params[:authentication])

    if @authentication.save && !@authentication.user.suspended?
      flash[:notice] = "Welcome to Fat Free CRM!"
      if @authentication.user.login_count > 1 && @authentication.user.last_login_at?
        flash[:notice] << " Your last login was on " << @authentication.user.last_login_at.strftime("%A, %B %e at %I:%M %p.")
      end
      redirect_back_or_default root_url
    else
      if @authentication.user.awaits_approval?
        flash[:notice] = "Your account has not been approved yet."
      else
        flash[:warning] = "Invalid username or password."
      end
      redirect_to :action => :new
    end
  end

  # The login form gets submitted to :update action when @authentication is
  # saved (@authentication != nil) but the user is suspended.
  #----------------------------------------------------------------------------
  alias :update :create

  #----------------------------------------------------------------------------
  def destroy
    current_user_session.destroy
    flash[:notice] = "You have been logged out. Thank you for using Fat Free CRM!"
    redirect_back_or_default login_url
  end

end
