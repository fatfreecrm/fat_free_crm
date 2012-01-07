# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
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

class ContactsController < BaseController
  before_filter :get_users, :only => [ :new, :create, :edit, :update ]
  before_filter :get_accounts, :only => [ :new, :create, :edit, :update ]

  # GET /contacts
  #----------------------------------------------------------------------------
  def index
    @contacts = get_contacts(:page => params[:page])
    respond_with(@contacts)
  end

  # GET /contacts/1
  #----------------------------------------------------------------------------
  def show
    @contact = Contact.my.find(params[:id])

    respond_with(@contact) do |format|
      format.html do
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@contact)
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :json, :xml)
  end

  # GET /contacts/new
  #----------------------------------------------------------------------------
  def new
    @contact  = Contact.new(:user => current_user, :access => Setting.default_access)
    @account  = Account.new(:user => current_user)
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.my.find(id))
    end
    respond_with(@contact)

  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @contact  = Contact.my.find(params[:id])
    @account  = @contact.account || Account.new(:user => current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Contact.my.find($1)
    end
    respond_with(@contact)

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @contact
  end

  # POST /contacts
  #----------------------------------------------------------------------------
  def create
    @contact = Contact.new(params[:contact])

    respond_with(@contact) do |format|
      if @contact.save_with_account_and_permissions(params)
        @contacts = get_contacts if called_from_index_page?
      else
        unless params[:account][:id].blank?
          @account = Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(.+)$/
            @account = Account.find($1) # related account
          else
            @account = Account.new(:user => current_user)
          end
        end
        @opportunity = Opportunity.find(params[:opportunity]) unless params[:opportunity].blank?
      end
    end
  end

  # PUT /contacts/1
  #----------------------------------------------------------------------------
  def update
    @contact = Contact.my.find(params[:id])

    respond_with(@contact) do |format|
      unless @contact.update_with_account_and_permissions(params)
        @users = User.except(current_user)
        if @contact.account
          @account = Account.find(@contact.account.id)
        else
          @account = Account.new(:user => current_user)
        end
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /contacts/1
  #----------------------------------------------------------------------------
  def destroy
    @contact = Contact.my.find(params[:id])
    @contact.destroy if @contact

    respond_with(@contact) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  # PUT /contacts/1/attach
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :attach

  # POST /contacts/1/discard
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :discard

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /contacts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = current_user.pref[:contacts_per_page] || Contact.per_page
      @outline  = current_user.pref[:contacts_outline]  || Contact.outline
      @sort_by  = current_user.pref[:contacts_sort_by]  || Contact.sort_by
      @naming   = current_user.pref[:contacts_naming]   || Contact.first_name_position
    end
  end

  # GET /contacts/opportunities                                            AJAX
  #----------------------------------------------------------------------------
  def opportunities
    @contact = Contact.my.find(params[:id])
  end

  # POST /contacts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:contacts_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:contacts_outline]  = params[:outline]  if params[:outline]

    # Sorting and naming only: set the same option for Leads if the hasn't been set yet.
    if params[:sort_by]
      current_user.pref[:contacts_sort_by] = Contact::sort_by_map[params[:sort_by]]
      if Lead::sort_by_fields.include?(params[:sort_by])
        current_user.pref[:leads_sort_by] ||= Lead::sort_by_map[params[:sort_by]]
      end
    end
    if params[:naming]
      current_user.pref[:contacts_naming] = params[:naming]
      current_user.pref[:leads_naming] ||= params[:naming]
    end

    @contacts = get_contacts(:page => 1) # Start one the first page.
    render :index
  end

  private
  #----------------------------------------------------------------------------
  def get_contacts(options = {})
    get_list_of_records(Contact, options)
  end

  def get_accounts
    @accounts = Account.my.order("name")
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        @contacts = get_contacts
        if @contacts.blank?
          @contacts = get_contacts(:page => current_page - 1) if current_page > 1
          render :index and return
        end
      else
        self.current_page = 1
      end
      # At this point render destroy.js.rjs
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @contact.full_name)
      redirect_to contacts_path
    end
  end
end
