class CampaignsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_current_tab, :only => [ :index, :show ]
  after_filter  :update_recently_viewed, :only => :show

  # GET /campaigns
  # GET /campaigns.xml                                            AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @campaigns = get_campaigns(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @campaigns }
    end
  end

  # GET /campaigns/1
  # GET /campaigns/1.xml
  #----------------------------------------------------------------------------
  def show
    @campaign = Campaign.find(params[:id])
    @stage = Setting.as_hash(:opportunity_stage)
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @campaign }
    end
  end

  # GET /campaigns/new
  # GET /campaigns/new.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def new
    @campaign = Campaign.new(:user => @current_user)
    @users = User.all_except(@current_user)
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @campaign }
    end
  end

  # GET /campaigns/1/edit                                                  AJAX
  #----------------------------------------------------------------------------
  def edit
    @campaign = Campaign.find(params[:id])
    @users = User.all_except(@current_user)
    if params[:previous] =~ /(\d+)\z/
      @previous = Campaign.find($1)
    end
  end

  # POST /campaigns
  # POST /campaigns.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def create
    @campaign = Campaign.new(params[:campaign])
    @users = User.all_except(@current_user)

    respond_to do |format|
      if @campaign.save_with_permissions(params[:users])
        @campaigns = get_campaigns
        get_data_for_sidebar
        format.js   # create.js.rjs
        format.xml  { render :xml => @campaign, :status => :created, :location => @campaign }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /campaigns/1
  # PUT /campaigns/1.xml                                                   AJAX
  #----------------------------------------------------------------------------
  def update
    @campaign = Campaign.find(params[:id])

    respond_to do |format|
      if @campaign.update_with_permissions(params[:campaign], params[:users])
        get_data_for_sidebar if called_from_index_page?
        format.js
        format.xml  { head :ok }
      else
        @users = User.all_except(@current_user) # Need it to redraw [Edit Campaign] form.
        format.js
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.xml                                       HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end
  end

  # GET /campaigns/search/query                                           AJAX
  #----------------------------------------------------------------------------
  def search
    @campaigns = get_campaigns(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @campaigns.to_xml }
    end
  end


  # Ajax request to filter out list of campaigns.                          AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_campaign_status] = params[:status]
    @campaigns = get_campaigns(:page => 1)
    render :action => :index
  end

  private
  #----------------------------------------------------------------------------
  def get_campaigns(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    if session[:filter_by_campaign_status]
      filters = session[:filter_by_campaign_status].split(",")
      current_query.blank? ? Campaign.my(@current_user).only(filters) : Campaign.my(@current_user).only(filters).search(current_query)
    else
      current_query.blank? ? Campaign.my(@current_user) : Campaign.my(@current_user).search(current_query)
    end.paginate(:page => current_page)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      get_data_for_sidebar
      @campaigns = get_campaigns
      if @campaigns.blank?
        @campaigns = get_campaigns(:page => current_page - 1) if current_page > 1
        render :action => :index and return
      end
      # At this point render destroy.js.rjs
    else # :html request
      self.current_page = 1
      flash[:notice] = "#{@campaign.name} has beed deleted."
      redirect_to(campaigns_path)
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @campaign_status_total = { :all => Campaign.my(@current_user).count, :other => 0 }
    Setting.campaign_status.keys.each do |key|
      @campaign_status_total[key] = Campaign.my(@current_user).count(:conditions => [ "status=?", key.to_s ])
      @campaign_status_total[:other] -= @campaign_status_total[key]
    end
    @campaign_status_total[:other] += @campaign_status_total[:all]
  end

end
