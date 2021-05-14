# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class ListsController < ApplicationController
  # POST /lists
  #----------------------------------------------------------------------------
  def create
    list_params[:user_id] = (current_user.id if params[:is_global].to_i.zero?)

    # Find any existing list with the same name (case insensitive)
    if @list = List.where("lower(name) = ?", list_params[:name].downcase).where(user_id: list_params[:user_id]).first
      @list.update(list_params)
    else
      @list = List.create(list_params)
    end

    respond_with(@list)
  end

  # DELETE /lists/1
  #----------------------------------------------------------------------------
  def destroy
    @list = List.find(params[:id])
    @list.destroy

    respond_with(@list)
  end

  protected

  def list_params
    params.require(:list).permit(
      :name,
      :url,
      :user_id
    )
  end
end
