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
    @event.event_instances.build
    
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
    
    event_start_date = params[:event][:event_instances_attributes]['0'][:calendar_start_date]
    
    if params[:repeating_event]      
      case params[:repeat_pattern]
      when "S1-adl"
        semester_start_date = Setting.academic_dates[:t1_start]
        semester_end_date = Setting.academic_dates[:t2_end_adl]
        hol_start_date = Setting.academic_dates[:t1_end]
        hol_end_date = Setting.academic_dates[:t2_start]
      when "S1-usa"
        semester_start_date = Setting.academic_dates[:t1_start]
        semester_end_date = Setting.academic_dates[:t2_end_usa]
        hol_start_date = Setting.academic_dates[:t1_end]
        hol_end_date = Setting.academic_dates[:t2_start]
      when "S2-adl"
        semester_start_date = Setting.academic_dates[:t3_start]
        semester_end_date = Setting.academic_dates[:t4_end_adl]
        hol_start_date = Setting.academic_dates[:t3_end]
        hol_end_date = Setting.academic_dates[:t4_start]
      when "S2-usa"
        semester_start_date = Setting.academic_dates[:t3_start]
        semester_end_date = Setting.academic_dates[:t4_end_adl]
        hol_start_date = Setting.academic_dates[:t3_end]
        hol_end_date = Setting.academic_dates[:t4_start]
      else
        debugger #error!
      end
    
      unless event_start_date.blank?
        #if start date is before the term starts, just bump it up until the start of term
        adjusted_start = (Time.parse(event_start_date) < Time.parse(semester_start_date)) ? semester_start_date : event_start_date          
        schedule = IceCube::Schedule.new(Time.parse(adjusted_start))
        
        #except the mid semester break (settings record term start days, so go for day before and after)
        ((DateTime.parse(Time.parse(hol_start_date).to_s) + 1)..(DateTime.parse(Time.parse(hol_end_date).to_s) -1 )).each do |date| 
          schedule.add_exception_time(date)
        end
        
        #except public holidays
        #Setting.academic_dates[:public_holidays].split(",").each do |date_string|
        #  schedule.add_exception_time(DateTime.parse(Time.parse(date_string).to_s))
        #end
        
        #note that the schedule will start from the start date given on the form. This allows events to start say in week 3 of term
        schedule.add_recurrence_rule IceCube::Rule.weekly(1).day(Time.parse(event_start_date).strftime("%A").downcase.to_sym)
        list_of_dates = schedule.occurrences(Time.parse(semester_end_date))
        start_week = (Date.parse(semester_start_date)..list_of_dates.first.to_date).step(7).count
        list_of_event_instances = create_event_instances(list_of_dates, start_week)
      end
    else
      @event.event_instances.first.name = @event.name
      @event.event_instances.first.user = params[:user] ? User.find(params[:user]) : @current_user
      @event.event_instances.first.assigned_to = params[:assigned_to]
    end
    
    
    
    respond_with(@event) do |format|
      if @event.save
        #event_list.each.add_comment_by_user(@comment_body, current_user)
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

  def create_event_instances(list_of_dates, start_week)
    event_instances_list = []
    public_holidays = Setting.academic_dates[:public_holidays].split(",")
    
    event_instance_from_form = @event.event_instances.first
    @event.event_instances.clear #start clean
    
    list_of_dates.each do |d|
      unless public_holidays.include?(d.strftime('%d/%m/%Y'))
        new_event_instance = event_instance_from_form.dup
        new_event_instance.user = params[:user] ? User.find(params[:user]) : @current_user
        new_event_instance.assigned_to = params[:assigned_to]
        new_event_instance.calendar_start_date = d.strftime('%d/%m/%Y')
        new_event_instance.calendar_end_date = d.strftime('%d/%m/%Y')
        new_event_instance.name = "week " + start_week.to_s
        @event.event_instances << new_event_instance
      end
      start_week += 1
    end
  end

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
