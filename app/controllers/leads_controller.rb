class LeadsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter "set_current_tab(:leads)", :except => [ :new, :edit, :create, :destroy, :convert, :promote, :filter ]

  # GET /leads
  # GET /leads.xml
  #----------------------------------------------------------------------------
  def index
    unless session[:filter_by_lead_status]
      @leads = Lead.my(@current_user)
    else
      @leads = Lead.my(@current_user).only(session[:filter_by_lead_status].split(","))
    end

    make_new_lead if context_exists?(:create_lead)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leads }
    end
  end

  # GET /leads/1
  # GET /leads/1.xml
  #----------------------------------------------------------------------------
  def show
    @lead = Lead.find(params[:id])
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lead }
    end
  end

  # GET /leads/new
  # GET /leads/new.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def new
    make_new_lead
    @context = save_context(:create_lead)

    respond_to do |format|
      format.js   # new.js.rjs
      format.html # new.html.erb
      format.xml  { render :xml => @lead }
    end
  end

  # GET /leads/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @lead = Lead.find(params[:id])
    @users = User.all_except(@current_user)
    @campaigns = Campaign.my(@current_user).all(:order => "name")

    @context = save_context(:edit_lead)
    mark_context(:edit_lead) if @context != :edit_lead # Make [Convert] aware that the Edit form is up.
  end

  # POST /leads
  # POST /leads.xml                                                        AJAX
  #----------------------------------------------------------------------------
  def create
    @lead = Lead.new(params[:lead])
    @users = User.all_except(@current_user)
    @campaigns = Campaign.my(@current_user).all(:order => "name")
    @context = save_context(:create_lead)

    respond_to do |format|
      if @lead.save_with_permissions(params[:users])
        drop_context(@context)
        get_data_for_sidebar if request.referer =~ /leads$/
        format.js   # create.js.rjs
        format.html { redirect_to(@lead) }
        format.xml  { render :xml => @lead, :status => :created, :location => @lead }
      else
        format.js   # create.js.rjs
        format.html { render :action => "new" }
        format.xml  { render :xml => @lead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leads/1
  # PUT /leads/1.xml
  #----------------------------------------------------------------------------
  def update
    @lead = Lead.find(params[:id])

    respond_to do |format|
      if @lead.update_attributes(params[:lead])
        flash[:notice] = "Lead #{@lead.full_name} was successfully updated."
        format.html { redirect_to(@lead) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy

    # Update sidebar only when deleting a lead from /leads page.
    get_data_for_sidebar if request.referer =~ /leads$/

    respond_to do |format|
      format.js   # destroy.js.rjs
      format.html { redirect_to(leads_url) }
      format.xml  { head :ok }
    end
  end

  # GET /leads/1/convert
  # GET /leads/1/convert.xml                                               AJAX
  #----------------------------------------------------------------------------
  def convert
    @lead = Lead.find(params[:id])
    @context = save_context(:convert_lead)
    mark_context(:convert_lead) if @context != :convert_lead # Make [Edit] aware that the Convert form is up.

    if context_exists?(@context) || context_exists?(:edit_lead)
      @users = User.all_except(@current_user)
      @accounts = Account.my(@current_user).all(:order => "name")
      @account = Account.new(:user => @current_user, :name => @lead.company, :access => "Lead")
      @opportunity = Opportunity.new(:user => @current_user, :access => "Lead", :stage => "prospecting")
      @contact = Contact.new
    end
  end

  # PUT /leads/1/convert
  # PUT /leads/1/convert.xml                                               AJAX
  #----------------------------------------------------------------------------
  def promote
    @context = params[:context]
    @lead = Lead.find(params[:id])
    @users = User.all_except(@current_user)
    @context = save_context(:create_lead)

    respond_to do |format|
      @account, @opportunity, @contact = @lead.promote(params)
      @accounts = Account.my(@current_user).all(:order => "name")
      if @account.errors.empty? && @opportunity.errors.empty? && @contact.errors.empty?
        @lead.convert
        get_data_for_sidebar if request.referer =~ /leads$/ # Update sidebar only if converting from Leads page.
        drop_context(@context)
        format.js   # promote.js.rjs
        format.html { redirect_to(@lead) }
        format.xml  { head :ok }
      else
        format.js   # promote.js.rjs
        format.html { render :action => "convert" }
        format.xml  { render :xml => @account.errors + @opportunity.errors + @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Ajax request to filter out list of leads.
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_lead_status] = params[:status]
    @leads = Lead.my(@current_user).only(params[:status].split(","))

    render :update do |page|
      page[:leads].replace_html render(:partial => "lead", :collection => @leads)
    end
  end

  private
  #----------------------------------------------------------------------------
  def make_new_lead
    @lead = Lead.new
    @users = User.all_except(@current_user)
    @campaigns = Campaign.my(@current_user).all(:order => "name")
    find_related_asset_for(@lead)
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @lead_status_total = { :all => Lead.my(@current_user).count, :other => 0 }
    Setting.lead_status.keys.each do |key|
      @lead_status_total[key] = Lead.my(@current_user).count(:conditions => [ "status=?", key.to_s ])
      @lead_status_total[:other] -= @lead_status_total[key]
    end
    @lead_status_total[:other] += @lead_status_total[:all]
  end

end
