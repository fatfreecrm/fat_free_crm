class ContactsController < ApplicationController
  before_filter :require_user
  before_filter "set_current_tab(:contacts)"

  # GET /contacts
  # GET /contacts.xml
  #----------------------------------------------------------------------------
  def index
    @contacts = Contact.find(:all, :order => "id DESC")

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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/new
  # GET /contacts/new.xml
  #----------------------------------------------------------------------------
  def new
    @contact = Contact.new(:user => @current_user, :access => "Private")
    @account = Account.new(:user => @current_user, :access => "Private")
    @users = User.all_except(@current_user) # to manage account permissions
    @accounts = Account.find(:all, :order => "name")

    respond_to do |format|
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
  # POST /contacts.xml
  #----------------------------------------------------------------------------
  def create
    @contact = Contact.new(params[:contact])
    @account = Account.new(params[:account])
    @users = User.all_except(@current_user)
    @accounts = Account.find(:all, :order => "name")

    respond_to do |format|
      if @contact.save_with_account_and_permissions(params)
        flash[:notice] = "Contact #{h @contact.full_name} was successfully created."
        format.html { redirect_to(@contact) }
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
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
  # DELETE /contacts/1.xml
  #----------------------------------------------------------------------------
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to(contacts_url) }
      format.xml  { head :ok }
    end
  end
end
