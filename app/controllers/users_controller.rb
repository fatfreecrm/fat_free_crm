# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class UsersController < ApplicationController
  before_action :set_current_tab, only: %i[show opportunities_overview] # Don't hightlight any tabs.

  check_authorization

  load_and_authorize_resource # handles all security

  respond_to :html, only: %i[show new]

  # GET /users/1
  # GET /users/1.js
  #----------------------------------------------------------------------------
  def show
    @user = current_user if params[:id].nil?
    respond_with(@user)
  end

  # GET /users/1/edit.js
  #----------------------------------------------------------------------------
  def edit
    respond_with(@user)
  end

  # PUT /users/1
  # PUT /users/1.js
  #----------------------------------------------------------------------------
  def update
    @user.update_attributes(user_params)
    flash[:notice] = t(:msg_user_updated)
    respond_with(@user)
  end

  # GET /users/1/avatar
  # GET /users/1/avatar.js
  #----------------------------------------------------------------------------
  def avatar
    respond_with(@user)
  end

  # PUT /users/1/upload_avatar
  # PUT /users/1/upload_avatar.js
  #----------------------------------------------------------------------------
  def upload_avatar
    if params[:gravatar]
      @user.avatar = nil
      @user.save
      render
    else
      if params[:avatar]
        avatar = Avatar.create(avatar_params)
        if avatar.valid?
          @user.avatar = avatar
        else
          @user.avatar.errors.clear
          @user.avatar.errors.add(:image, t(:msg_bad_image_file))
        end
      end
      responds_to_parent do
        # Without return RSpec2 screams bloody murder about rendering twice:
        # within the block and after yield in responds_to_parent.
        render && (return if Rails.env.test?)
      end
    end
  end

  # GET /users/1/password
  # GET /users/1/password.js
  #----------------------------------------------------------------------------
  def password
    respond_with(@user)
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.js
  #----------------------------------------------------------------------------
  def change_password
    if @user.valid_password?(params[:current_password])
      if params[:user][:password].blank?
        flash[:notice] = t(:msg_password_not_changed)
      else
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
        @user.save
        flash[:notice] = t(:msg_password_changed)
      end
    else
      @user.errors.add(:current_password, t(:msg_invalid_password))
    end

    respond_with(@user)
  end

  # GET /users/1/redraw
  #----------------------------------------------------------------------------
  def redraw
    current_user.preference[:locale] = params[:locale]
    render js: %(window.location.href = "#{user_path(current_user)}";)
  end

  # GET /users/opportunities_overview
  #----------------------------------------------------------------------------
  def opportunities_overview
    @users_with_opportunities = User.have_assigned_opportunities.order(:first_name)
    @unassigned_opportunities = Opportunity.my(current_user).unassigned.pipeline.order(:stage).includes(:account, :user, :tags)
  end

  protected

  def user_params
    return {} unless params[:user]
    params[:user][:email].try(:strip!)
    params[:user].permit(
      :username,
      :email,
      :first_name,
      :last_name,
      :title,
      :company,
      :alt_email,
      :phone,
      :mobile,
      :aim,
      :yahoo,
      :google,
      :skype
    )
  end

  def avatar_params
    return {} unless params[:avatar]
    params[:avatar]
      .permit(:image)
      .merge(entity: @user)
  end
end
