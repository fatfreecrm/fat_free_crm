class ContactsController < ApplicationController
  before_filter :require_user
  before_filter "set_current_tab(:contacts)", :only => [ :index, :show ]

  # GET /contacts
  # GET /contacts.xml
  #----------------------------------------------------------------------------
  def index
    @contacts = Contact.my(@current_user)
    make_new_contact if context_exists?(:create_contact)

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
    @stage   = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }
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
    make_new_contact
    @context = save_context(:create_contact)

    respond_to do |format|
      format.js   # new.js.rjs
      format.html # new.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @contact  = Contact.find(params[:id])
    @users    = User.all_except(@current_user)
      @account  = Account.new
    @accounts = Account.my(@current_user).all(:order => "name")
    ### @context = save_context(dom_id(@contact))
    if params[:open] =~ /(\d+)\z/
      @previous = Contact.find($1)
    end
  end

  # POST /contacts
  # POST /contacts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @contact  = Contact.new(params[:contact])
    @users    = User.all_except(@current_user)
    @account  = Account.new(params[:account])
    @accounts = Account.my(@current_user).all(:order => "name")
    @context = save_context(:create_contact)

    respond_to do |format|
      if @contact.save_with_account_and_permissions(params)
        drop_context(@context)
        format.js   # create.js.rjs
        format.html { redirect_to(@contact) }
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        format.js   # create.js.rjs
        format.html { render :action => "new" }
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
      if @contact.update_attributes(params[:contact])
        flash[:notice] = 'Contact was successfully updated.'
        format.html { redirect_to(@contact) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
      format.html { redirect_to(contacts_url) }
      format.xml  { head :ok }
    end
  end

  private
  #----------------------------------------------------------------------------
  def make_new_contact
    @contact  = Contact.new(:user => @current_user, :access => "Private")
    @users    = User.all_except(@current_user)
    @account  = Account.new(:user => @current_user, :access => "Private")
    @accounts = Account.my(@current_user).all(:order => "name")
    find_related_asset_for(@contact)
  end

end
