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

class UsersController < ApplicationController

  before_filter :require_no_user, :only => [ :new, :create ]
  before_filter :authenticate_user!, :only => [ :show, :redraw ]
  before_filter :set_current_tab, :only => [ :show, :opportunities_overview ] # Don't hightlight any tabs.
  before_filter :require_and_assign_user, :except => [ :new, :create, :show, :avatar, :upload_avatar ]
  before_filter :assign_given_or_current_user, :only => [ :show, :avatar, :upload_avatar, :edit, :update ]

  load_resource

  respond_to :html, :only => [ :show, :new ]

  # GET /users/1
  # GET /users/1.json
  # GET /users/1.xml                                                       HTML
  #----------------------------------------------------------------------------
  def show
    respond_with(@user)
  end

  # GET /users/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    respond_with(@user)
  end

  # POST /users
  # POST /users.xml                                                        HTML
  #----------------------------------------------------------------------------
  # TODO: move into devise/registrations
  def create
    if @user.save
      if Setting.user_signup == :needs_approval
        flash[:notice] = t(:msg_account_created)
        redirect_to new_user_session_url
      else
        flash[:notice] = t(:msg_successful_signup)
        redirect_back_or_default profile_url
      end
    else
      render "devise/registrations/new"
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  # PUT /users/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  def update
    @user.update_attributes(params[:user])
    respond_with(@user)
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
    respond_with(@user)
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
          @user.avatar.errors.add(:image, t(:msg_bad_image_file))
        end
      end
      responds_to_parent do
        # Without return RSpec2 screams bloody murder about rendering twice:
        # within the block and after yield in responds_to_parent.
        render and (return if Rails.env.test?)
      end
    end
  end

  # GET /users/1/password
  # GET /users/1/password.xml                                              AJAX
  #----------------------------------------------------------------------------
  def password
    respond_with(@user)
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.xml                                       AJAX
  #----------------------------------------------------------------------------
  def change_password
    if @user.valid_password?(params[:current_password], true) || @user.password_hash.blank?
      unless params[:user][:password].blank?
        @user.update_attributes(params[:user])
        flash[:notice] = t(:msg_password_changed)
      else
        flash[:notice] = t(:msg_password_not_changed)
      end
    else
      @user.errors.add(:current_password, t(:msg_invalid_password))
    end

    respond_with(@user)
  end

  # POST /users/1/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.preference[:locale] = params[:locale]
    render(:update) { |page| page.redirect_to user_path(current_user) }
  end

  def opportunities_overview
    @users_with_opportunities = User.have_assigned_opportunities.order(:first_name)
    @unassigned_opportunities = Opportunity.unassigned.pipeline.order(:stage)
  end

  private

  #----------------------------------------------------------------------------
  def require_and_assign_user
    authenticate_user!
    @user = current_user
  end

  def assign_given_or_current_user
    @user = params[:id] ? User.find(params[:id]) : current_user
  end
end
