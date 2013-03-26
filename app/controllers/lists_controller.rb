# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class ListsController < ApplicationController

  # POST /lists
  #----------------------------------------------------------------------------
  def create
    # Find any existing list with the same name (case insensitive)
    if @list = List.find(:first, :conditions => ["lower(name) = ?", params[:list][:name].downcase])
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
