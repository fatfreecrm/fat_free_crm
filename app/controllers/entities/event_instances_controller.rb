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
class EventInstancesController < EntitiesController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /accounts
  #----------------------------------------------------------------------------
  def index
    @event_instances = get_event_instances(:page => params[:page])
    
    respond_with @event_instances do |format|
      format.xls { render :layout => 'header' }
    end
  end

  # GET /accounts/1
  #----------------------------------------------------------------------------
  def show
    @contacts = @event_instance.event.contact_group.nil? ? [] : @event_instance.event.contact_group.contacts
    @event_instance.attendances.each do |a|
      unless @contacts.member?(a.contact)
        @contacts << a.contact
      end  
    end
    respond_with(@event_instance) do |format|
      format.html do
        #@stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@event_instance)
      end
    end
  end

  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @event_instance.attributes = {:user => @current_user, :access => Setting.default_access}
    @users = User.except(@current_user)

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@event_instance)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @users = User.except(@current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Event.my.find_by_id($1) || $1.to_i
    end

    respond_with(@event_instance)
  end

  # POST /accounts
  #----------------------------------------------------------------------------
  def create
    @users = User.except(@current_user)
    #@comment_body = params[:comment_body]
    
    respond_with(@event_instance) do |format|
      if @event_instance.save_with_event_and_permissions(params)
        #@event_instance.add_comment_by_user(@comment_body, current_user)
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @event_instances = get_event_instances
        get_data_for_sidebar
      end
    end
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@event_instance) do |format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @event_instance.access = params[:event_instance][:access] if params[:event_instance][:access]
      if @event_instance.update_attributes(params[:event_instance])
        get_data_for_sidebar
      else
        @users = User.except(current_user) # Need it to redraw [Edit Account] form.
      end
    end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def destroy
    @event_instance.destroy

    respond_with(@event_instance) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end
  
  # PUT /tasks/1/complete
  #----------------------------------------------------------------------------
  def mark
    #debugger
    @contact = Contact.find(params[:contact_id])
    #@event_instance = EventInstance.find(event_instance)
    #check if already marked
    if @event_instance.attendances.where(:contact_id => @contact.id).empty?
    
      @attendance = Attendance.new(:contact => @contact)
      @event_instance.attendances << @attendance
    end
    #@attendance.save

    #update_sidebar unless params[:bucket].blank?
    respond_with(@contact)
  end
  
  # PUT /tasks/1/complete
  #----------------------------------------------------------------------------
  def unmark
    #debugger
    @contact = Contact.find(params[:contact_id])
    #@event_instance = EventInstance.find(event_instance)
    @attendances = @event_instance.attendances.where(:contact_id => @contact.id)
    
    @attendances.each do |a|
      @event_instance.attendances.delete(a)
    end
    #@attendance.save

    #update_sidebar unless params[:bucket].blank?
    respond_with(@contact)
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

  # POST /accounts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:event_instances_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:event_instances_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:event_instances_sort_by]  = EventInstance::sort_by_map[params[:sort_by]] if params[:sort_by]
    @event_instances = get_event_instances(:page => 1)
    render :index
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:event_instances_filter] = params[:category]
    @event_instances = get_event_instances(:page => 1)
    render :index
  end

private

  #----------------------------------------------------------------------------
  alias :get_event_instances :get_list_of_records

  # GET /accounts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def set_options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:event_instances_per_page] || EventInstance.per_page
      @outline  = @current_user.pref[:event_instances_outline]  || EventInstance.outline
      @sort_by  = @current_user.pref[:event_instances_sort_by]  || EventInstance.sort_by
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @event_instances = get_event_instances
      get_data_for_sidebar
      if @event_instances.empty?
        @event_instances = get_event_instances(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @event_instance.name)
      redirect_to event_instances_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
  #exposed variables to be displayed on sidebar
  end
end
