# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------
class ContactsController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :attach, :only => :attach
  before_filter :discard, :only => :discard
  before_filter :auto_complete, :only => :auto_complete
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
    @stage = Setting.unroll(:opportunity_stage)
    @comment = Comment.new
    
    @timeline = Timeline.find(@contact)

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
    @contact  = Contact.new(:user => @current_user, :access => Setting.default_access)
    @account  = Account.new(:user => @current_user)
    @users    = User.except(@current_user).active.all
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
    @users    = User.except(@current_user).active.all
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
        @users = User.except(@current_user).active.all
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
        @users = User.except(@current_user).active.all
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

  # PUT /contacts/1/attach
  # PUT /contacts/1/attach.xml                                             AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :attach, :only => :attach

  # POST /contacts/1/discard
  # POST /contacts/1/discard.xml                                           AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :discard, :only => :discard

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :auto_complete, :only => :auto_complete

  # GET /contacts/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @contacts = get_contacts(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @contacts.to_xml }
    end
  end

  # GET /contacts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:contacts_per_page] || Contact.per_page
      @outline  = @current_user.pref[:contacts_outline]  || Contact.outline
      @sort_by  = @current_user.pref[:contacts_sort_by]  || Contact.sort_by
      @naming   = @current_user.pref[:contacts_naming]   || Contact.first_name_position
    end
  end

  # POST /contacts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:contacts_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:contacts_outline]  = params[:outline]  if params[:outline]

    # Sorting and naming only: set the same option for Leads if the hasn't been set yet.
    if params[:sort_by]
      @current_user.pref[:contacts_sort_by] = Contact::sort_by_map[params[:sort_by]]
      if Lead::sort_by_fields.include?(params[:sort_by])
        @current_user.pref[:leads_sort_by] ||= Lead::sort_by_map[params[:sort_by]]
      end
    end
    if params[:naming]
      @current_user.pref[:contacts_naming] = params[:naming]
      @current_user.pref[:leads_naming] ||= params[:naming]
    end

    @contacts = get_contacts(:page => 1) # Start one the first page.
    render :action => :index
  end

  private
  #----------------------------------------------------------------------------
  def get_contacts(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.pref[:contacts_sort_by] || Contact.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.pref[:contacts_per_page]
    }

    # Call :get_contacts hook and return its output if any.
    contacts = hook(:get_contacts, self, :records => records, :pages => pages)
    return contacts.last unless contacts.empty?

    # Default processing if no :get_contacts hooks are present.
    if current_query.blank?
      Contact.my(records)
    else
      Contact.my(records).search(current_query)
    end.paginate(pages)
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
      flash[:notice] = t(:msg_asset_deleted, @contact.full_name)
      redirect_to(contacts_path)
    end
  end

end
