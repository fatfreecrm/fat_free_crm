class LeadsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_current_tab, :only => [ :index, :show ]
  after_filter  :update_recently_viewed, :only => :show

  # GET /leads
  # GET /leads.xml                                                AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @leads = get_leads(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js   # index.js.rjs
      format.xml  { render :xml => @leads }
    end
  end

  # GET /leads/1
  # GET /leads/1.xml                                                       HTML
  #----------------------------------------------------------------------------
  def show
    @lead = Lead.find(params[:id])
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lead }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { flash[:warning] = "This lead is no longer available."; redirect_to(:action => :index) }
      format.xml  { render :status => :not_found }
    end
  end

  # GET /leads/new
  # GET /leads/new.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def new
    @lead = Lead.new
    @users = User.all_except(@current_user)
    @campaigns = Campaign.my(@current_user).all(:order => "name")
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @lead }
    end
  end

  # GET /leads/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @lead = Lead.find(params[:id])
    @users = User.all_except(@current_user)
    @campaigns = Campaign.my(@current_user).all(:order => "name")
    if params[:previous] =~ /(\d+)\z/
      @previous = Lead.find($1)
    end
  end

  # POST /leads
  # POST /leads.xml                                                        AJAX
  #----------------------------------------------------------------------------
  def create
    @lead = Lead.new(params[:lead])
    @users = User.all_except(@current_user)
    @campaigns = Campaign.my(@current_user).all(:order => "name")

    respond_to do |format|
      if @lead.save_with_permissions(params)
        if called_from_index_page?
          @leads = get_leads
          get_data_for_sidebar
        end
        format.js   # create.js.rjs
        format.xml  { render :xml => @lead, :status => :created, :location => @lead }
      else
        format.js   # create.js.rjs
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
      if @lead.update_with_permissions(params[:lead], params[:users])
        get_data_for_sidebar if called_from_index_page?
        format.js
        format.xml  { head :ok }
      else
        @users = User.all_except(@current_user)
        @campaigns = Campaign.my(@current_user).all(:order => "name")
        format.js
        format.xml  { render :xml => @lead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.xml                                           HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end
  end

  # GET /leads/1/convert
  # GET /leads/1/convert.xml                                               AJAX
  #----------------------------------------------------------------------------
  def convert
    @lead = Lead.find(params[:id])
    @users = User.all_except(@current_user)
    @account = Account.new(:user => @current_user, :name => @lead.company, :access => "Lead")
    @accounts = Account.my(@current_user).all(:order => "name")
    @opportunity = Opportunity.new(:user => @current_user, :access => "Lead", :stage => "prospecting")
  end

  # PUT /leads/1/promote
  # PUT /leads/1/promote.xml                                               AJAX
  #----------------------------------------------------------------------------
  def promote
    @lead = Lead.find(params[:id])
    @users = User.all_except(@current_user)
    @account, @opportunity, @contact = @lead.promote(params)
    @accounts = Account.my(@current_user).all(:order => "name")

    respond_to do |format|
      if @account.errors.empty? && @opportunity.errors.empty? && @contact.errors.empty?
        @lead.convert
        get_data_for_sidebar if called_from_index_page?
        format.js   # promote.js.rjs
        format.xml  { head :ok }
      else
        format.js   # promote.js.rjs
        format.xml  { render :xml => @account.errors + @opportunity.errors + @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leads/1/reject
  # PUT /leads/1/reject.xml                                       AJAX and HTML
  #----------------------------------------------------------------------------
  def reject
    @lead = Lead.find(params[:id])
    @lead.reject
    get_data_for_sidebar if called_from_index_page?

    respond_to do |format|
      format.html { flash[:notice] = "#{@lead.full_name} has beed rejected."; redirect_to(leads_path) }
      format.js   # reject.js.rjs
      format.xml  { head :ok }
    end
  end

  # GET /leads/search/query                                                AJAX
  #----------------------------------------------------------------------------
  def search
    @leads = get_leads(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @leads.to_xml }
    end
  end

  # Ajax request to filter out list of leads.                              AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_lead_status] = params[:status]
    @leads = get_leads(:page => 1) # Start one the first page.
    render :action => :index
  end

  private
  #----------------------------------------------------------------------------
  def get_leads(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    if session[:filter_by_lead_status]
      filters = session[:filter_by_lead_status].split(",")
      current_query.blank? ? Lead.my(@current_user).only(filters) : Lead.my(@current_user).only(filters).search(current_query)
    else
      current_query.blank? ? Lead.my(@current_user) : Lead.my(@current_user).search(current_query)
    end.paginate(:page => current_page)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?                  # Called from Leads index.
        get_data_for_sidebar                      # Get data for the sidebar.
        @leads = get_leads                        # Get leads for current page.
        if @leads.blank?                          # If no lead on this page then try the previous one.
          @leads = get_leads(:page => current_page - 1) if current_page > 1
          render :action => :index and return     # And reload the whole list even if it's empty.
        end
      else                                        # Called from related asset.
        self.current_page = 1                     # Reset current page to 1 to make sure it stays valid.
      end                                         # Render destroy.js.rjs
    else # :html destroy
      self.current_page = 1
      flash[:notice] = "#{@lead.full_name} has beed deleted."
      redirect_to(leads_path)
    end
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
