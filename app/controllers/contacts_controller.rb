class ContactsController < ApplicationController
  before_filter :require_user
  before_filter "set_current_tab(:contacts)", :only => [ :index, :show ]

  # GET /contacts
  # GET /contacts.xml
  #----------------------------------------------------------------------------
  def index
    @contacts = Contact.my(@current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  #----------------------------------------------------------------------------
  def show
    @contact = Contact.find(params[:id])
    @stage = Setting.as_hash(:opportunity_stage)
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/new
  # GET /contacts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @contact  = Contact.new(:user => @current_user)
    @account  = Account.new(:user => @current_user)
    @users    = User.all_except(@current_user)
    @accounts = Account.my(@current_user).all(:order => "name")
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @contact  = Contact.find(params[:id])
    @users    = User.all_except(@current_user)
    @account  = @contact.account || Account.new(:user => @current_user)
    @accounts = Account.my(@current_user).all(:order => "name")
    if params[:previous] =~ /(\d+)\z/
      @previous = Contact.find($1)
    end
  end

  # POST /contacts
  # POST /contacts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @contact = Contact.new(params[:contact])

    respond_to do |format|
      if @contact.save_with_account_and_permissions(params)
        format.js   # create.js.rjs
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        @users = User.all_except(@current_user)
        @accounts = Account.my(@current_user).all(:order => "name")
        if params[:account][:id].blank?
          @account = Account.new(:user => @current_user)
        else
          @account = Account.find(params[:account][:id])
        end
        format.js   # create.js.rjs
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    @contact = Contact.find(params[:id])

    respond_to do |format|
      if @contact.update_with_account_and_permissions(params)
        format.js
        format.xml  { head :ok }
      else
        @users = User.all_except(@current_user)
        @accounts = Account.my(@current_user).all(:order => "name")
        if params[:account][:id].blank?
          @account = Account.new(:user => @current_user)
        else
          @account = Account.find(params[:account][:id])
        end
        format.js
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.js
      format.xml  { head :ok }
    end
  end

end
