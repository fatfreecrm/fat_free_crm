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

class AuthenticationsController < ApplicationController

  before_filter :require_no_user, :only => [ :new, :create, :show ]
  before_filter :require_user, :only => :destroy

  #----------------------------------------------------------------------------
  def new
    @authentication = Authentication.new
  end

  #----------------------------------------------------------------------------
  def show
    redirect_to login_url
  end

  #----------------------------------------------------------------------------
  def create
    @authentication = Authentication.new(params[:authentication])

    if @authentication.save && !@authentication.user.suspended?
      flash[:notice] = t(:msg_welcome)
      if @authentication.user.login_count > 1 && @authentication.user.last_login_at?
        flash[:notice] << " " << t(:msg_last_login, l(@authentication.user.last_login_at, :format => :mmddhhss))
      end
      redirect_back_or_default root_url
    else
      if @authentication.user && @authentication.user.awaits_approval?
        flash[:notice] = t(:msg_account_not_approved)
      else
        flash[:warning] = t(:msg_invalig_login)
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
    flash[:notice] = t(:msg_goodbye)
    redirect_back_or_default login_url
  end

end
