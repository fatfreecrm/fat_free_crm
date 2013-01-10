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
class ContactsController < EntitiesController
  before_filter :get_accounts, :only => [ :new, :create, :edit, :update ]
  before_filter :check_for_mobile
  before_filter :get_data_for_sidebar, :only => :index
  
  def single_access_allowed?
    (action_name == "mailchimp_webhooks" || action_name == "mandrill_webhooks")
  end
  
  def confirm
    respond_with(@contact)
  end
  
  def mandrill_webhooks
    if request.post?
      data = JSON.parse(params['mandrill_events'])
      case data[0]['event']
      #just implementing hard bounce for now
      when "hard_bounce"
        contact = Contact.find_by_email(data[0]['msg']['email'])
        if contact.present?
          contact.tasks << Task.new(
                    :name => "Email bounced!", 
                    :category => :email, 
                    :bucket => "due_this_week", 
                    :user => @current_user , 
                    :assigned_to => User.find_by_first_name("geoff").id
                    )
          contact.comments << Comment.new(
                    :user_id => 1,
                    :comment => "Email bounced\nDescription: #{data[0]['msg']['bounce_description']}\nServer said: #{data[0]['msg']['diag']}"
                    )
        end
      end
    end
  end
  
  def mailchimp_webhooks
    if request.post?
      list_id = params[:data][:list_id]
      #if list_id.nil? raise some error
      list_name = Setting.mailchimp.find{|k,v| v == list_id}[0] # "eg. city_west_list_id"
      list_name = list_name.split("_list_id")[0] # eg "city_west" NOPE!!
      list_name = list_name.humanize.titleize # eg " City West"
      
      case params[:type]
      when "subscribe"
        logger.info("Subscribe request received")
        if contact = Contact.find_or_create_by_email(params[:data][:email])
          #not generating the right list name
          #TODO - check if changed in the last few minutes and ignore - webhook fired when we do subcribes from here
          contact.cf_weekly_emails << list_name unless (contact.cf_weekly_emails.include?(list_name) || list_name == "Supporters")
          contact.cf_supporters_emails = [params[:data]["merges"]["GROUPINGS"]["0"]["groups"]] if list_name == "Supporters"
          contact.first_name = params[:data]["merges"]["FNAME"]
          contact.last_name = params[:data]["merges"]["LNAME"]
          contact.user = @current_user if contact.user.nil?
          #TODO:get gender, campus, assign task to user accordingly
          contact.tasks << Task.new(:name => "New signup to #{list_name} - send welcome email", :category => :email, :bucket => "due_this_week", :user => @current_user)
        end
      when "unsubscribe"
        logger.info("Unsubscribe request received")
        if contact = Contact.find_by_email(params[:data][:email])
          if list_name == "Supporters"
            contact.cf_supporters_emails = []
          else
            contact.cf_weekly_emails = contact.cf_weekly_emails - [list_name]
          end
          contact.tasks << Task.new(:name => "followup unsubscribe from mailchimp list #{list_name}", :category => :follow_up, :bucket => "due_this_week", :user => @current_user)
        end
      when "upemail"
        if contact = Contact.find_by_email(params[:data][:old_email])
          contact.email = params[:data][:new_email]
        end
      when "profile" 
        if contact = Contact.find_by_email(params[:data][:email])
          contact.first_name = params[:data]["merges"]["FNAME"]
          contact.last_name = params[:data]["merges"]["LNAME"]
        end
      when "cleaned"
        if contact = Contact.find_by_email(params[:data][:email])
          reason = params[:data][:reason] == "hard" ? "the email bounced" : "the email was reported as spam"
          contact.cf_weekly_emails = contact.cf_weekly_emails - [list_name]
          contact.tasks << Task.new(:name => "unsubscribed from #{list_name} becuase #{reason}", :category => :follow_up, :bucket => "due_this_week", :user => @current_user)
        end
      end
      contact.save
    else # GET
      respond_with @contacts do |format|
        format.html
      end
    end  
  end
  
  # GET /contacts
  #----------------------------------------------------------------------------
  def index
    @contacts = get_contacts(:page => params[:page], :per_page => params[:per_page])

    respond_with @contacts do |format|
      format.xls { render :layout => 'header' }
    end
  end

  # GET /contacts/1
  # AJAX /contacts/1
  #----------------------------------------------------------------------------
  def show
    @stage = Setting.unroll(:opportunity_stage)
    @comment = Comment.new
    @timeline = timeline(@contact)
    @contact_groups = @contact.contact_groups
    @bsg_attendances = @contact.attendances.where('events.category = ?', "bsg").order('event_instances.starts_at DESC').includes(:event, :event_instance)
    @tbt_attendances = @contact.attendances.where('events.category = ?', "bible_talk").order('event_instances.starts_at DESC').includes(:event, :event_instance)
    @other_attendances = @contact.attendances.where('events.category NOT IN (?)', ["bsg", "bible_talk"]).order('event_instances.starts_at DESC').includes(:event, :event_instance)
    respond_with(@contact)
  end

  # GET /contacts/new
  #----------------------------------------------------------------------------
  def new
    @contact.attributes = {:user => current_user, :access => Setting.default_access, :assigned_to => nil}
    @account = Account.new(:user => current_user)
    if called_from_landing_page?(:event_instances)
      @event_instance = EventInstance.find(params[:event_instance_id])
    end
    if params[:related]
      model = params[:related].sub(/_\d+/, "")
      id = params[:related].split('_').last #change required for models with _ in name e.g. contact_group
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end

    respond_with(@contact)
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @account = @contact.account || Account.new(:user => current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Contact.my.find_by_id($1) || $1.to_i
    end
    if params[:related]
      model = params[:related].sub(/_\d+/, "")
      id = params[:related].split('_').last #change required for models with _ in name e.g. contact_group
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end

    respond_with(@contact)
  end

  # POST /contacts
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    if called_from_landing_page?(:event_instances)
      @event_instance = EventInstance.find(params[:event_instance])
    end
    respond_with(@contact) do |format|
      if @contact.save_with_account_and_permissions(params)
        @contact.add_comment_by_user(@comment_body, current_user)
        @contacts = get_contacts if called_from_index_page?
        get_data_for_sidebar
      else
        unless params[:account][:id].blank?
          @account = Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(.+)$/
            @account = Account.find($1) # related account
          else
            @account = Account.new(:user => current_user)
          end
        end
        @opportunity = Opportunity.my.find(params[:opportunity]) unless params[:opportunity].blank?
      end
    end
  end

  # PUT /contacts/1
  #----------------------------------------------------------------------------
  def update
    if params[:related]
      model = params[:related].sub(/_\d+/, "")
      id = params[:related].split('_').last #change required for models with _ in name e.g. contact_group
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end
    
    respond_with(@contact) do |format|
      unless @contact.update_with_account_and_permissions(params)
        if @contact.account
          @account = Account.find(@contact.account.id)
        else
          @account = Account.new(:user => current_user)
        end
      else
        get_data_for_sidebar
      end
    end
  end

  # DELETE /contacts/1
  #----------------------------------------------------------------------------
  def destroy
    @contact.delete_chimp_all
    @contact.destroy

    respond_with(@contact) do |format|
      get_data_for_sidebar
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end
  
  def graduate
    @contact.cf_weekly_emails = [""]
    @contact.cf_year_graduated = Setting.graduate[:year]
    @contact.account = Account.find_by_name(Setting.graduate[:account])
    @contact.save
    
    respond_with(@contact) do |format|
      get_data_for_sidebar
    end
  end

  def attendances
    
  end
  # PUT /contacts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # POST /contacts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # POST /contacts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:contacts_per_page] = params[:per_page] if params[:per_page]

    # Sorting and naming only: set the same option for Leads if the hasn't been set yet.
    if params[:sort_by]
      current_user.pref[:contacts_sort_by] = Contact::sort_by_map[params[:sort_by]]
      if Lead::sort_by_fields.include?(params[:sort_by])
        current_user.pref[:leads_sort_by] ||= Lead::sort_by_map[params[:sort_by]]
      end
    end
    if params[:naming]
      current_user.pref[:contacts_naming] = params[:naming]
      current_user.pref[:leads_naming] ||= params[:naming]
    end

    @contacts = get_contacts(:page => 1, :per_page => params[:per_page]) # Start on the first page.
    set_options # Refresh options
    
    respond_with(@contacts) do |format|
      format.js { render :index }
    end
  end
  
  # POST /contacts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:contacts_filter] = params[:folder]
    @contacts = get_contacts(:page => 1)
    render :index
  end
  
  def options
    get_data_for_sidebar
    render :options
  end

  private
  #----------------------------------------------------------------------------
  alias :get_contacts :get_list_of_records

  #----------------------------------------------------------------------------
  def get_accounts
    @accounts = Account.my.order('name')
  end

  def set_options
    super
    @naming = (current_user.pref[:contacts_naming]   || Contact.first_name_position) unless params[:cancel].true?
  end
  
  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @folder_total = Hash[
      Account.my.map do |key|
        [ key, key.contacts.count ]
      end
    ]
    organized = @folder_total.values.sum
    @folder_total[:all] = Contact.my.count
    @folder_total[:other] = @folder_total[:all] - organized
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        @contacts = get_contacts
        if @contacts.blank?
          @contacts = get_contacts(:page => current_page - 1) if current_page > 1
          render :index and return
        end
      else
        self.current_page = 1
      end
      # At this point render destroy.js.rjs
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @contact.full_name)
      redirect_to contacts_path
    end
  end
end
