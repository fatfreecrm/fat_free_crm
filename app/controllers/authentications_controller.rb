# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class AuthenticationsController < ApplicationController
  before_action :require_no_user, only: [:new, :create, :show]
  before_action :require_user, only: :destroy

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
    @authentication = Authentication.new(params[:authentication].permit(:username, :password, :remember_me))

    if @authentication.save && !@authentication.user.suspended?
      flash[:notice] = t(:msg_welcome)
      if @authentication.user.login_count > 1 && @authentication.user.last_login_at?
        flash[:notice] << " " << t(:msg_last_login, l(@authentication.user.last_login_at, format: :mmddhhss))
      end
      redirect_back_or_default root_url
    else
      if @authentication.user && @authentication.user.awaits_approval?
        flash[:notice] = t(:msg_account_not_approved)
      else
        flash[:warning] = t(:msg_invalig_login)
      end
      redirect_to action: :new
    end
  end

  # The login form gets submitted to :update action when @authentication is
  # saved (@authentication != nil) but the user is suspended.
  #----------------------------------------------------------------------------
  alias_method :update, :create

  #----------------------------------------------------------------------------
  def destroy
    current_user_session.destroy
    flash[:notice] = t(:msg_goodbye)
    redirect_back_or_default login_url
  end
end
