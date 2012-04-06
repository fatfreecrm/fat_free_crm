class Admin::GroupsController < Admin::ApplicationController

  load_resource

  # GET /groups
  #----------------------------------------------------------------------------
  def index
    @groups = @groups.paginate(:page => params[:page])
  end

  # GET /groups/1
  #----------------------------------------------------------------------------
  def show
    respond_with(@group)
  end

  # GET /groups/new
  #----------------------------------------------------------------------------
  def new
    respond_with(@group)
  end

  # GET /groups/1/edit
  #----------------------------------------------------------------------------
  def edit
    respond_with(@group)
  end

  # POST /groups
  #----------------------------------------------------------------------------
  def create
    @group.update_attributes(params[:group])

    respond_with(@group)
  end

  # PUT /groups/1
  #----------------------------------------------------------------------------
  def update
    @group.update_attributes(params[:group])

    respond_with(@group)
  end

  # DELETE /groups/1
  #----------------------------------------------------------------------------
  def destroy
    @group.destroy

    respond_with(@group)
  end
end
