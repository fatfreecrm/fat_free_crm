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

class ContactGroupsController < EntitiesController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /accounts
  #----------------------------------------------------------------------------
  def index
    @contact_groups = get_contact_groups(:page => params[:page])
    
    respond_with @contact_groups do |format|
      format.xls { render :layout => 'header' }
    end
  end

  # GET /accounts/1
  #----------------------------------------------------------------------------
  def show
    respond_with(@contact_group) do |format|
      format.html do
        #@stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@contact_group)
      end
    end
  end

  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @contact_group.attributes = {:user => @current_user, :access => Setting.default_access}
    @users = User.except(@current_user)

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@contact_group)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @users = User.except(@current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = ContactGroup.my.find_by_id($1) || $1.to_i
    end

    respond_with(@contact_group)
  end

  # POST /accounts
  #----------------------------------------------------------------------------
  def create
    @users = User.except(@current_user)

    respond_with(@contact_group) do |format|
      if @contact_group.save_with_permissions(params[:users])
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @contact_groups = get_contact_groups
        get_data_for_sidebar
      end
    end
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@contact_group) do |format|
      if @contact_group.update_with_permissions(params[:contact_group], params[:users])
        get_data_for_sidebar
      else
        @users = User.except(@current_user) # Need it to redraw [Edit Account] form.
      end
    end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def destroy
    @contact_group.destroy

    respond_with(@contact_group) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /accounts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # PUT /accounts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /accounts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:contact_groups_per_page] || ContactGroup.per_page
      @outline  = @current_user.pref[:contact_groups_outline]  || ContactGroup.outline
      @sort_by  = @current_user.pref[:contact_groups_sort_by]  || ContactGroup.sort_by
    end
  end

  # POST /accounts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:contact_groups_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:contact_groups_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:contact_groups_sort_by]  = ContactGroup::sort_by_map[params[:sort_by]] if params[:sort_by]
    @contact_groups = get_contact_groups(:page => 1)
    render :index
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:contact_groups_filter] = params[:category]
    @contact_groups = get_contact_groups(:page => 1)
    render :index
  end

private

  #----------------------------------------------------------------------------
  alias :get_contact_groups :get_list_of_records

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @contact_groups = get_contact_groups
      get_data_for_sidebar
      if @contact_groups.empty?
        @contact_groups = get_contact_groups(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @contact_group.name)
      redirect_to contact_groups_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @contact_group_category_total = Hash[
      Setting.contact_group_category.map do |key|
        [ key, ContactGroup.my.where(:category => key.to_s).count ]
      end
    ]
    categorized = @contact_group_category_total.values.sum
    @contact_group_category_total[:all] = ContactGroup.my.count
    @contact_group_category_total[:other] = @contact_group_category_total[:all] - categorized
  end
end
