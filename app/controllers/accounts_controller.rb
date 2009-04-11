class AccountsController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  after_filter  :update_recently_viewed, :only => :show

  # GET /accounts
  # GET /accounts.xml
  #----------------------------------------------------------------------------
  def index
    @accounts = Account.my(@current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  #----------------------------------------------------------------------------
  def show
    @account = Account.find(params[:id])
    @stage = Setting.as_hash(:opportunity_stage)
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @account = Account.new(:user => @current_user)
    @users = User.all_except(@current_user)
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
    @account = Account.find(params[:id])
    @users = User.all_except(@current_user)
    if params[:previous] =~ /(\d+)\z/
      @previous = Account.find($1)
    end
  end

  # POST /accounts
  # POST /accounts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @account = Account.new(params[:account])
    @users = User.all_except(@current_user)

    respond_to do |format|
      if @account.save_with_permissions(params[:users])
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
        @users = User.all_except(@current_user) # Need it to redraw [Edit Account] form.
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
      format.html { flash[:notice] = "#{@account.name} has beed deleted."; redirect_to(accounts_path) }
      format.js   # destroy.js.rjs
      format.xml  { head :ok }
    end
  end

end
