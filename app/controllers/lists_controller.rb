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
    list_attr = list_params.to_h
    list_attr["user_id"] = current_user.id if params["is_global"] != "1"

    # Find any existing list with the same name (case insensitive)
    if @list = List.where("lower(name) = ?", list_attr[:name].downcase).where(user_id: list_attr[:user_id]).first
      @list.update(list_attr)
    else
      @list = List.create(list_attr)
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

  ActiveSupport.run_load_hooks(:fat_free_crm_lists_controller, self)
end
