class ListsController < ApplicationController
  respond_to :js

  # POST /lists
  #----------------------------------------------------------------------------
  def create
    return unless params[:list]
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
    #TODO
  end
end
