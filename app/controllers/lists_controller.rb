class ListsController < ApplicationController
  respond_to :js

  # POST /lists
  #----------------------------------------------------------------------------
  def create
    @list = List.new(params[:list])
    @list.save
    respond_with(@list)
  end

  # DELETE /lists/1
  #----------------------------------------------------------------------------
  def destroy
    #TODO
  end
end
