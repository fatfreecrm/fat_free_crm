class CampaignsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter "set_current_tab(:campaigns)", :except => [ :new, :create, :edit, :update, :destroy, :filter ]

  # GET /campaigns
  # GET /campaigns.xml
  #----------------------------------------------------------------------------
  def index
    unless session[:filter_by_campaign_status]
      @campaigns = Campaign.my(@current_user)
    else
      @campaigns = Campaign.my(@current_user).only(session[:filter_by_campaign_status].split(","))
    end

    make_new_campaign if context_exists?(:create_campaign)

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @campaigns }
    end
  end

  # GET /campaigns/1
  # GET /campaigns/1.xml
  #----------------------------------------------------------------------------
  def show
    @campaign = Campaign.find(params[:id])
    @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }
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
    make_new_campaign
    @context = save_context(:create_campaign)

    respond_to do |format|
      format.js   # new.js.rjs
      format.html # new.html.haml
      format.xml  { render :xml => @campaign }
    end
  end

  # GET /campaigns/1/edit                                                  AJAX
  #----------------------------------------------------------------------------
  def edit
    @campaign = Campaign.find(params[:id])
    @users    = User.all_except(@current_user)
    @context  = save_context(dom_id(@campaign))
    if params[:open] =~ /(\d+)\z/
      @previous = Campaign.find($1)
    end
  end

  # POST /campaigns
  # POST /campaigns.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def create
    @campaign = Campaign.new(params[:campaign])
    @users = User.all_except(@current_user)
    @context = save_context(:create_campaign)

    respond_to do |format|
      if @campaign.save_with_permissions(params[:users])
        drop_context(@context)
        format.js   # create.js.rjs
        format.html { redirect_to(@campaign) }
        format.xml  { render :xml => @campaign, :status => :created, :location => @campaign }
      else
        format.js   # create.js.rjs
        format.html { render :action => "new" }
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
      if @campaign.update_attributes(params[:campaign])
        format.js
        format.html { redirect_to(@campaign) }
        format.xml  { head :ok }
      else
        @users = User.all_except(@current_user) # Need it to redraw [Edit Campaign] form.
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.xml                                                AJAX
  #----------------------------------------------------------------------------
  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy

    respond_to do |format|
      format.js   { get_data_for_sidebar; render }
      format.html { redirect_to(campaigns_url) }
      format.xml  { head :ok }
    end
  end

  # Ajax request to filter out list of campaigns.                          AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_campaign_status] = params[:status]
    @campaigns = Campaign.my(@current_user).only(params[:status].split(","))

    render :update do |page|
      page[:campaigns].replace_html render(:partial => "campaign", :collection => @campaigns)
    end
  end

  private
  #----------------------------------------------------------------------------
  def make_new_campaign
    @campaign = Campaign.new
    @users = User.all_except(@current_user)
    find_related_asset_for(@campaign)
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
