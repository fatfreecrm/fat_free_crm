class OpportunitiesController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter "set_current_tab(:opportunities)", :except => [ :new, :create, :destroy, :filter ]

  # GET /opportunities
  # GET /opportunities.xml
  #----------------------------------------------------------------------------
  def index
    unless session[:filter_by_opportunity_stage]
      @opportunities = Opportunity.my(@current_user)
    else
      @opportunities = Opportunity.my(@current_user).only(session[:filter_by_opportunity_stage].split(","))
    end
    make_new_opportunity if visible?(:create_opportunity)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @opportunities }
    end
  end

  # GET /opportunities/1
  # GET /opportunities/1.xml
  #----------------------------------------------------------------------------
  def show
    @opportunity = Opportunity.find(params[:id])
    @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @opportunity }
    end
  end

  # GET /opportunities/new
  # GET /opportunities/new.xml                                             AJAX
  #----------------------------------------------------------------------------
  def new
    preserve_visibility(:create_opportunity)
    make_new_opportunity

    respond_to do |format|
      format.js   # new.js.rjs
      format.html # new.html.erb
      format.xml  { render :xml => @opportunity }
    end
  end

  # GET /opportunities/1/edit
  #----------------------------------------------------------------------------
  def edit
    @opportunity = Opportunity.find(params[:id])
  end

  # POST /opportunities
  # POST /opportunities.xml                                                AJAX
  #----------------------------------------------------------------------------
  def create
    @opportunity = Opportunity.new(params[:opportunity])
    @users       = User.all_except(@current_user)
    @account     = Account.new(params[:account])
    @accounts    = Account.my(@current_user).all(:order => "name")
    @stage       = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }
    preserve_visibility(:create_opportunity)

    respond_to do |format|
      if @opportunity.save_with_account_and_permissions(params)
        drop_visibility(:create_opportunity)
        get_data_for_sidebar if request.referer =~ /opportunities$/
        format.js   # create.js.rjs
        format.html { redirect_to(@opportunity) }
        format.xml  { render :xml => @opportunity, :status => :created, :location => @opportunity }
      else
        format.js   # create.js.rjs
        format.html { render :action => "new" }
        format.xml  { render :xml => @opportunity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /opportunities/1
  # PUT /opportunities/1.xml
  #----------------------------------------------------------------------------
  def update
    @opportunity = Opportunity.find(params[:id])

    respond_to do |format|
      if @opportunity.update_attributes(params[:opportunity])
        flash[:notice] = 'Opportunity was successfully updated.'
        format.html { redirect_to(@opportunity) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @opportunity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /opportunities/1
  # DELETE /opportunities/1.xml                                            AJAX
  #----------------------------------------------------------------------------
  def destroy
    @opportunity = Opportunity.find(params[:id])
    @opportunity.destroy
    get_data_for_sidebar if request.referer =~ /opportunities$/

    respond_to do |format|
      format.js   { get_data_for_sidebar; render }
      format.html { redirect_to(opportunities_url) }
      format.xml  { head :ok }
    end
  end

  # Ajax request to filter out list of opportunities.                      AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_opportunity_stage] = params[:stage]
    @opportunities = Opportunity.my(@current_user).only(params[:stage].split(","))
    @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }

    render :update do |page|
      page[:opportunities].replace_html render(:partial => "opportunity", :collection => @opportunities)
    end
  end

  private
  #--------------------------------------------------------------------------
  def make_new_opportunity
    @opportunity = Opportunity.new(:user => @current_user, :access => "Private", :stage => "prospecting")
    @users       = User.all_except(@current_user)
    @account     = Account.new(:user => @current_user, :access => "Private")
    @accounts    = Account.my(@current_user).all(:order => "name")
    find_related_asset_for(@opportunity)
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }
    @opportunity_stage_total = { :all => Opportunity.my(@current_user).count, :other => 0 }
    @stage.keys.each do |key|
      @opportunity_stage_total[key] = Opportunity.my(@current_user).count(:conditions => [ "stage=?", key.to_s ])
      @opportunity_stage_total[:other] -= @opportunity_stage_total[key]
    end
    @opportunity_stage_total[:other] += @opportunity_stage_total[:all]
  end

end
