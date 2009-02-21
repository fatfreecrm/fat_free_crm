class ContactsController < ApplicationController
  before_filter :require_user
  before_filter "set_current_tab(:contacts)", :except => [ :new, :create, :destroy ]

  # GET /contacts
  # GET /contacts.xml
  #----------------------------------------------------------------------------
  def index
    @contacts = Contact.my(@current_user)
    make_new_contact if session["create_contact"]

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
    @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }
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
    @context = (params[:context].blank? ? "create_contact" : params[:context])
    session[@context] = (params[:visible] == "true" ? nil : true)

    respond_to do |format|
      format.js   # new.js.rjs
      format.html # new.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/1/edit
  #----------------------------------------------------------------------------
  def edit
    @contact = Contact.find(params[:id])
  end

  # POST /contacts
  # POST /contacts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @contact = Contact.new(params[:contact])
    @account = Account.new(params[:account])
    @users = User.all_except(@current_user)
    @accounts = Account.my(@current_user).all(:order => "name")
    @context = (params[:context].blank? ? "create_contact" : params[:context])

    respond_to do |format|
      if @contact.save_with_account_and_permissions(params)
        session[@context] = nil
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
  # PUT /contacts/1.xml
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
end
