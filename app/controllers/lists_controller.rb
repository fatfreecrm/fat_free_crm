# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class ListsController < ApplicationController

  # POST /lists
  #----------------------------------------------------------------------------
  def create

    if params[:is_global].to_i.zero?
      params[:list][:user_id] = current_user.id
    else
      params[:list][:user_id] = nil
    end

    # Find any existing list with the same name (case insensitive)
    if @list = List.where("lower(name) = ?", params[:list][:name].downcase).where({:user_id => params[:list][:user_id]}).first
      @list.update_attributes(params[:list])
    else
      @list = List.create(params[:list])
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
end
