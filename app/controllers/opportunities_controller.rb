class OpportunitiesController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :load_settings, :only => [ :index, :show,  :edit, :create, :update, :filter ]
  before_filter :get_data_for_sidebar, :only => :index
  after_filter  :update_recently_viewed, :only => :show

  # GET /opportunities
  # GET /opportunities.xml
  #----------------------------------------------------------------------------
  def index
    @opportunities = get_opportunities

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
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
  # GET /opportunities/new.xml                                             AJAX
  #----------------------------------------------------------------------------
  def new
    @opportunity = Opportunity.new(:user => @current_user, :stage => "prospecting")
    @users       = User.all_except(@current_user)
    @account     = Account.new(:user => @current_user)
    @accounts    = Account.my(@current_user).all(:order => "name")
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @opportunity }
    end
  end

  # GET /opportunities/1/edit                                              AJAX
  #----------------------------------------------------------------------------
  def edit
    @opportunity = Opportunity.find(params[:id])
    @users = User.all_except(@current_user)
    @account  = @opportunity.account || Account.new(:user => @current_user)
    @accounts = Account.my(@current_user).all(:order => "name")
    if params[:previous] =~ /(\d+)\z/
      @previous = Opportunity.find($1)
    end
  end

  # POST /opportunities
  # POST /opportunities.xml                                                AJAX
  #----------------------------------------------------------------------------
  def create
    @opportunity = Opportunity.new(params[:opportunity])

    respond_to do |format|
      if @opportunity.save_with_account_and_permissions(params)
        if called_from_index_page?
          @opportunities = get_opportunities
          get_data_for_sidebar
        end
        format.js   # create.js.rjs
        format.xml  { render :xml => @opportunity, :status => :created, :location => @opportunity }
      else
        @users = User.all_except(@current_user)
        @accounts = Account.my(@current_user).all(:order => "name")
        unless params[:account][:id].blank?
          @account = Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(.+)$/
            @account = Account.find($1) # related account
          else
            @account = Account.new(:user => @current_user)
          end
        end
        @contact = Contact.find(params[:contact]) unless params[:contact].blank?
        @campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
        format.js   # create.js.rjs
        format.xml  { render :xml => @opportunity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /opportunities/1
  # PUT /opportunities/1.xml                                               AJAX
  #----------------------------------------------------------------------------
  def update
    @opportunity = Opportunity.find(params[:id])

    respond_to do |format|
      if @opportunity.update_with_account_and_permissions(params)
        get_data_for_sidebar if called_from_index_page?
        format.js
        format.xml  { head :ok }
      else
        @users = User.all_except(@current_user)
        @accounts = Account.my(@current_user).all(:order => "name")
        if @opportunity.account
          @account = Account.find(@opportunity.account.id)
        else
          @account = Account.new(:user => @current_user)
        end
        format.js
        format.xml  { render :xml => @opportunity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /opportunities/1
  # DELETE /opportunities/1.xml                                   HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @opportunity = Opportunity.find(params[:id])
    @opportunity.destroy

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end
  end

  # Ajax request to filter out list of opportunities.                      AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_opportunity_stage] = params[:stage]
    session[:opportunities_current_page] = 1
    @opportunities = get_opportunities
    render :action => :index
  end

  private
  #----------------------------------------------------------------------------
  def get_opportunities
    @page = get_current_page
    unless session[:filter_by_opportunity_stage]
      @opportunities = Opportunity.my(@current_user)
    else
      @opportunities = Opportunity.my(@current_user).only(session[:filter_by_opportunity_stage].split(","))
    end.paginate(:page => @page)
  end

  #----------------------------------------------------------------------------
  def get_current_page
    page = params[:page] || session[:opportunities_current_page] || 1
    session[:opportunities_current_page] = page.to_i
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        get_data_for_sidebar
        @opportunities = get_opportunities
        if @opportunities.blank?
          if session[:opportunities_current_page] > 1
            session[:opportunities_current_page] -= 1
            @opportunities = get_opportunities
          end
          render :action => :index and return
        end
      else # Called from related asset.
        session[:opportunities_current_page] = 1
      end
      # At this point render destroy.js.rjs
    else
      session[:opportunities_current_page] = 1
      flash[:notice] = "#{@opportunity.name} has beed deleted."
      redirect_to(opportunities_path)
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    load_settings
    @opportunity_stage_total = { :all => Opportunity.my(@current_user).count, :other => 0 }
    @stage.keys.each do |key|
      @opportunity_stage_total[key] = Opportunity.my(@current_user).count(:conditions => [ "stage=?", key.to_s ])
      @opportunity_stage_total[:other] -= @opportunity_stage_total[key]
    end
    @opportunity_stage_total[:other] += @opportunity_stage_total[:all]
  end

  #----------------------------------------------------------------------------
  def load_settings
    @stage = Setting.as_hash(:opportunity_stage)
  end

end
