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
class EventsController < EntitiesController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /accounts
  #----------------------------------------------------------------------------
  def index
    @events = get_events(:page => params[:page])
    respond_with @events do |format|
      format.xls { render :layout => 'header' }
    end
  end

  # GET /accounts/1
  #----------------------------------------------------------------------------
  def show
    @contacts = @event.contact_group.nil? ? [] : @event.contact_group.contacts
    @event.attendances.each do |a|
      unless @contacts.member?(a.contact)
        @contacts << a.contact
      end  
    end  
    respond_with(@event) do |format|
      format.html do
        #@stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@event)
      end
    end
  end

  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @event.attributes = {:user => @current_user, :access => Setting.default_access}
    @users = User.except(@current_user)

    if params[:related]
      model = params[:related].sub(/_\d+/, "")
      id = params[:related].split('_').last #change required for models with _ in name e.g. contact_group
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@event)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @contact_group = @event.contact_group
    @users = User.except(@current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Event.my.find_by_id($1) || $1.to_i
    end

    respond_with(@event)
  end

  # POST /accounts
  #----------------------------------------------------------------------------
  def create
    @users = User.except(@current_user)
    @comment_body = params[:comment_body]
    
    respond_with(@event) do |format|
      if @event.save
        @event.add_comment_by_user(@comment_body, current_user)
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @events = get_events
        get_data_for_sidebar
      end
    end
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@event) do |format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @event.access = params[:event][:access] if params[:event][:access]
      if @event.update_attributes(params[:event])
        get_data_for_sidebar
      else
        @users = User.except(current_user) # Need it to redraw [Edit Account] form.
      end
    end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def destroy
    @event.destroy

    respond_with(@event) do |format|
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
    if @event.attendances.where(:contact_id => @contact.id).empty?
    
      @attendance = Attendance.new(:contact => @contact)
      @event.attendances << @attendance
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
    @attendances = @event.attendances.where(:contact_id => @contact.id)
    
    @attendances.each do |a|
      @event.attendances.delete(a)
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
    @current_user.pref[:events_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:events_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:events_sort_by]  = Event::sort_by_map[params[:sort_by]] if params[:sort_by]
    @events = get_events(:page => 1)
    render :index
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:events_filter] = params[:category]
    @events = get_events(:page => 1)
    render :index
  end

private

  #----------------------------------------------------------------------------
  alias :get_events :get_list_of_records

  # GET /accounts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def set_options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:events_per_page] || Event.per_page
      @outline  = @current_user.pref[:events_outline]  || Event.outline
      @sort_by  = @current_user.pref[:events_sort_by]  || Event.sort_by
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @events = get_events
      get_data_for_sidebar
      if @events.empty?
        @events = get_events(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @event.name)
      redirect_to events_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @event_category_total = Hash[
      Setting.event_category.map do |key|
        [ key, Event.my.where(:category => key.to_s).count ]
      end
    ]
    categorized = @event_category_total.values.sum
    @event_category_total[:all] = Event.my.count
    @event_category_total[:other] = @event_category_total[:all] - categorized
  end
end
