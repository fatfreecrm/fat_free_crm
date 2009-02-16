class OpportunitiesController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter "set_current_tab(:opportunities)", :except => :filter

  # GET /opportunities
  # GET /opportunities.xml
  #----------------------------------------------------------------------------
  def index
    unless session[:filter_by_opportunity_stage]
      @opportunities = Opportunity.my(@current_user)
    else
      @opportunities = Opportunity.my(@current_user).only(session[:filter_by_opportunity_stage].split(","))
    end

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
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @opportunity }
    end
  end

  # GET /opportunities/new
  # GET /opportunities/new.xml
  #----------------------------------------------------------------------------
  def new
    @opportunity = Opportunity.new(:user => @current_user, :access => "Private", :stage => "prospecting")
    @account = Account.new(:user => @current_user, :access => "Private")
    @users = User.all_except(@current_user)
    @accounts = Account.my(@current_user).all(:order => "name")

    respond_to do |format|
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
  # POST /opportunities.xml
  #----------------------------------------------------------------------------
  def create
    @opportunity = Opportunity.new(params[:opportunity])
    @account = Account.new(params[:account])
    @users = User.all_except(@current_user)
    @accounts = Account.my(@current_user).all(:order => "name")

    respond_to do |format|
      if @opportunity.save_with_account_and_permissions(params)
        flash[:notice] = 'Opportunity was successfully created.'
        format.html { redirect_to(@opportunity) }
        format.xml  { render :xml => @opportunity, :status => :created, :location => @opportunity }
      else
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
  # DELETE /opportunities/1.xml
  #----------------------------------------------------------------------------
  def destroy
    @opportunity = Opportunity.find(params[:id])
    @opportunity.destroy

    respond_to do |format|
      format.html { redirect_to(opportunities_url) }
      format.xml  { head :ok }
      format.js   { get_data_for_sidebar; render }
    end
  end

  # Ajax request to filter out list of opportunities.
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_opportunity_stage] = params[:stage]
    @opportunities = Opportunity.my(@current_user).only(params[:stage].split(","))
    @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }

    render :update do |page|
      page[:list].replace_html render(:partial => "opportunity", :collection => @opportunities)
    end
  end

  private
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
