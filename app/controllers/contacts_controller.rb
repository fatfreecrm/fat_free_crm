class ContactsController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  after_filter  :update_recently_viewed, :only => :show

  # GET /contacts
  # GET /contacts.xml                                             AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @contacts = get_contacts(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show
    @contact = Contact.my(@current_user).find(params[:id])
    @stage = Setting.as_hash(:opportunity_stage)
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /contacts/new
  # GET /contacts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @contact  = Contact.new(:user => @current_user)
    @account  = Account.new(:user => @current_user)
    @users    = User.except(@current_user).all
    @accounts = Account.my(@current_user).all(:order => "name")
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.my(@current_user).find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @contact }
    end

  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @contact  = Contact.my(@current_user).find(params[:id])
    @users    = User.except(@current_user).all
    @account  = @contact.account || Account.new(:user => @current_user)
    @accounts = Account.my(@current_user).all(:order => "name")
    if params[:previous] =~ /(\d+)\z/
      @previous = Contact.my(@current_user).find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @contact
  end

  # POST /contacts
  # POST /contacts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @contact = Contact.new(params[:contact])

    respond_to do |format|
      if @contact.save_with_account_and_permissions(params)
        @contacts = get_contacts if called_from_index_page?
        format.js   # create.js.rjs
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        @users = User.except(@current_user).all
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
        @opportunity = Opportunity.find(params[:opportunity]) unless params[:opportunity].blank?
        format.js   # create.js.rjs
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    @contact = Contact.my(@current_user).find(params[:id])

    respond_to do |format|
      if @contact.update_with_account_and_permissions(params)
        format.js
        format.xml  { head :ok }
      else
        @users = User.except(@current_user).all
        @accounts = Account.my(@current_user).all(:order => "name")
        if @contact.account
          @account = Account.find(@contact.account.id)
        else
          @account = Account.new(:user => @current_user)
        end
        format.js
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @contact = Contact.my(@current_user).find(params[:id])
    @contact.destroy if @contact

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # GET /contacts/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @contacts = get_contacts(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @contacts.to_xml }
    end
  end

  # POST /leads/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  def auto_complete
    @query = params[:auto_complete_query]
    @auto_complete = Contact.my(@current_user).search(@query).limit(10)
    session[:auto_complete] = :contacts
    render :template => "common/auto_complete", :layout => nil
  end

  private
  #----------------------------------------------------------------------------
  def get_contacts(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    if current_query.blank?
      Contact.my(@current_user)
    else
      Contact.my(@current_user).search(current_query)
    end.paginate(:page => current_page)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        @contacts = get_contacts
        if @contacts.blank?
          @contacts = get_contacts(:page => current_page - 1) if current_page > 1
          render :action => :index and return
        end
      else
        self.current_page = 1
      end
      # At this point render destroy.js.rjs
    else
      self.current_page = 1
      flash[:notice] = "#{@contact.full_name} has beed deleted."
      redirect_to(contacts_path)
    end
  end

end
