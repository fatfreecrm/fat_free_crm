class LeadsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter "set_current_tab(:leads)", :except => :filter

  # GET /leads
  # GET /leads.xml
  #----------------------------------------------------------------------------
  def index
    unless session[:filter_by_lead_status]
      @leads = Lead.my(@current_user)
    else
      @leads = Lead.my(@current_user).only(session[:filter_by_lead_status].split(","))
    end

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
  # GET /leads/new.xml
  #----------------------------------------------------------------------------
  def new
    @lead = Lead.new
    @users = User.all_except(@current_user)
    @campaigns = Campaign.my(@current_user).all(:order => "name")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lead }
    end
  end

  # GET /leads/1/edit
  #----------------------------------------------------------------------------
  def edit
    @lead = Lead.find(params[:id])
  end

  # POST /leads
  # POST /leads.xml
  #----------------------------------------------------------------------------
  def create
    @lead = Lead.new(params[:lead])
    @users = User.all_except(@current_user)
    @campaigns = Campaign.my(@current_user).all(:order => "name")

    respond_to do |format|
      if @lead.save_with_permissions(params[:users])
        flash[:notice] = "Lead #{@lead.full_name} was successfully created."
        format.html { redirect_to(@lead) }
        format.xml { render :xml => @lead, :status => :created, :location => @lead }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @lead.errors, :status => :unprocessable_entity }
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
  # DELETE /leads/1.xml
  #----------------------------------------------------------------------------
  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy

    respond_to do |format|
      format.html { redirect_to(leads_url) }
      format.xml  { head :ok }
      format.js   { get_data_for_sidebar; render }
    end
  end

  # GET /leads/1/convert
  # GET /leads/1/convert.xml
  #----------------------------------------------------------------------------
  def convert
    @lead = Lead.find(params[:id])
    @users = User.all_except(@current_user)
    @accounts = Account.my(@current_user).all(:order => "name")
    @account = Account.new(:user => @current_user, :access => "Lead")
    @opportunity = Opportunity.new(:user => @current_user, :access => "Lead", :stage => "prospecting")
    @contact = Contact.new
  end

  # PUT /leads/1/convert
  # PUT /leads/1/convert.xml
  #----------------------------------------------------------------------------
  def promote
    @lead = Lead.find(params[:id])
    @users = User.all_except(@current_user)

    respond_to do |format|
      @account, @opportunity, @contact = @lead.promote(params)
      @accounts = Account.my(@current_user).all(:order => "name")
      if @account.errors.empty? && @opportunity.errors.empty? && @contact.errors.empty?
        @lead.convert(!@opportunity.id.nil?)
        flash[:notice] = "Lead #{@lead.full_name} was successfully converted."
        format.html { redirect_to(@lead) }
        format.xml  { head :ok }
      else
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
      page[:list].replace_html render(:partial => "lead", :collection => @leads)
    end
  end

  private
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
