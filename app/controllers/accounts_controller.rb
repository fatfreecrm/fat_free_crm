class AccountsController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  after_filter  :update_recently_viewed, :only => :show

  # GET /accounts
  # GET /accounts.xml                                             HTML and AJAX
  #----------------------------------------------------------------------------
  def index
    @accounts = get_accounts(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show
    @account = Account.my(@current_user).find(params[:id])
    @stage = Setting.as_hash(:opportunity_stage)
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @account }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { flash[:warning] = "This account is no longer available."; redirect_to(:action => :index) }
      format.xml  { render :status => :not_found }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @account = Account.new(:user => @current_user)
    @users = User.except(@current_user).all
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @account = Account.my(@current_user).find(params[:id])
    @users = User.except(@current_user).all
    if params[:previous] =~ /(\d+)\z/
      @previous = Account.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    flash[:warning] = "This account is no longer available."
    render(:update) { |page| page.reload }
  end

  # POST /accounts
  # POST /accounts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @account = Account.new(params[:account])
    @users = User.except(@current_user).all

    respond_to do |format|
      if @account.save_with_permissions(params[:users])
        # None: account can only be created from the Accounts index page, so we 
        # don't have to check whether we're on the index page.
        @accounts = get_accounts
        format.js   # create.js.rjs
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_with_permissions(params[:account], params[:users])
        format.js
        format.xml  { head :ok }
      else
        @users = User.except(@current_user).all # Need it to redraw [Edit Account] form.
        format.js
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end
  end

  # GET /accounts/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @accounts = get_accounts(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @accounts.to_xml }
    end
  end

  private
  #----------------------------------------------------------------------------
  def get_accounts(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    if current_query.blank?
      Account.my(@current_user)
    else
      Account.my(@current_user).search(current_query)
    end.paginate(:page => current_page)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @accounts = get_accounts
      if @accounts.blank?
        @accounts = get_accounts(:page => current_page - 1) if current_page > 1
        render :action => :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = "#{@account.name} has beed deleted."
      redirect_to(accounts_path)
    end
  end

end
