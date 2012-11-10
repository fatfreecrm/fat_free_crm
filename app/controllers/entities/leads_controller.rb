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

class LeadsController < EntitiesController
  before_filter :get_data_for_sidebar, :only => :index
  autocomplete :account, :name, :full => true

  # GET /leads
  #----------------------------------------------------------------------------
  def index
    @leads = get_leads(:page => params[:page])

    respond_with @leads do |format|
       format.xls { render :layout => 'header' }
    end
  end

  # GET /leads/1
  #----------------------------------------------------------------------------
  def show
    respond_with(@lead) do |format|
      format.html do
        @comment = Comment.new
        @timeline = timeline(@lead)
      end
    end
  end

  # GET /leads/new
  #----------------------------------------------------------------------------
  def new
    @lead.attributes = {:user => current_user, :access => Setting.default_access, :assigned_to => nil}
    @users = User.except(current_user)
    get_campaigns

    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end

    respond_with(@lead)
  end

  # GET /leads/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @users = User.except(current_user)
    get_campaigns

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Lead.my.find_by_id($1) || $1.to_i
    end

    respond_with(@lead)
  end

  # POST /leads
  #----------------------------------------------------------------------------
  def create
    @users = User.except(current_user)
    get_campaigns
    @comment_body = params[:comment_body]

    respond_with(@lead) do |format|
      if @lead.save_with_permissions(params)
        @lead.add_comment_by_user(@comment_body, current_user)
        if called_from_index_page?
          @leads = get_leads
          get_data_for_sidebar
        else
          get_data_for_sidebar(:campaign)
        end
      end
    end
  end

  # PUT /leads/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@lead) do |format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @lead.access = params[:lead][:access] if params[:lead][:access]
      if @lead.update_with_lead_counters(params[:lead])
        update_sidebar
      else
        @users = User.except(current_user)
        @campaigns = Campaign.my.order('name')
      end
    end
  end

  # DELETE /leads/1
  #----------------------------------------------------------------------------
  def destroy
    @lead.destroy

    respond_with(@lead) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # GET /leads/1/convert
  #----------------------------------------------------------------------------
  def convert
    @users = User.except(current_user)
    @account = Account.new(:user => current_user, :name => @lead.company, :access => "Lead")
    @accounts = Account.my.order('name')
    @opportunity = Opportunity.new(:user => current_user, :access => "Lead", :stage => "prospecting", :campaign => @lead.campaign, :source => @lead.source)

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Lead.my.find_by_id($1) || $1.to_i
    end

    respond_with(@lead)
  end

  # PUT /leads/1/promote
  #----------------------------------------------------------------------------
  def promote
    @users = User.except(current_user)
    @account, @opportunity, @contact = @lead.promote(params)
    @accounts = Account.my.order('name')
    @stage = Setting.unroll(:opportunity_stage)

    respond_with(@lead) do |format|
      if @account.errors.empty? && @opportunity.errors.empty? && @contact.errors.empty?
        @lead.convert
        update_sidebar
      else
        format.json { render :json => @account.errors + @opportunity.errors + @contact.errors, :status => :unprocessable_entity }
        format.xml  { render :xml => @account.errors + @opportunity.errors + @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leads/1/reject
  #----------------------------------------------------------------------------
  def reject
    @lead.reject
    update_sidebar

    respond_with(@lead) do |format|
      format.html { flash[:notice] = t(:msg_asset_rejected, @lead.full_name); redirect_to leads_path }
    end
  end

  # PUT /leads/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # POST /leads/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /leads/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete


  # POST /leads/redraw                                                     AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:leads_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:leads_outline]  = params[:outline]  if params[:outline]

    # Sorting and naming only: set the same option for Contacts if the hasn't been set yet.
    if params[:sort_by]
      current_user.pref[:leads_sort_by] = Lead::sort_by_map[params[:sort_by]]
      if Contact::sort_by_fields.include?(params[:sort_by])
        current_user.pref[:contacts_sort_by] ||= Contact::sort_by_map[params[:sort_by]]
      end
    end
    if params[:naming]
      current_user.pref[:leads_naming] = params[:naming]
      current_user.pref[:contacts_naming] ||= params[:naming]
    end

    @leads = get_leads(:page => 1, :per_page => params[:per_page]) # Start one the first page.
    set_options # Refresh options
    render :index
  end

  # POST /leads/filter                                                     AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:leads_filter] = params[:status]
    @leads = get_leads(:page => 1, :per_page => params[:per_page]) # Start one the first page.
    render :index
  end

private

  #----------------------------------------------------------------------------
  alias :get_leads :get_list_of_records

  #----------------------------------------------------------------------------
  def get_campaigns
    @campaigns = Campaign.my.order('name')
  end

  def set_options
    super
    @naming = (current_user.pref[:leads_naming] || Lead.first_name_position) unless params[:cancel].true?
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?                  # Called from Leads index.
        get_data_for_sidebar                      # Get data for the sidebar.
        @leads = get_leads                        # Get leads for current page.
        if @leads.blank?                          # If no lead on this page then try the previous one.
          @leads = get_leads(:page => current_page - 1) if current_page > 1
          render :index and return                # And reload the whole list even if it's empty.
        end
      else                                        # Called from related asset.
        self.current_page = 1                     # Reset current page to 1 to make sure it stays valid.
        @campaign = @lead.campaign                # Reload lead's campaign if any.
      end                                         # Render destroy.js.rjs
    else # :html destroy
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @lead.full_name)
      redirect_to leads_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar(related = false)
    if related
      instance_variable_set("@#{related}", @lead.send(related)) if called_from_landing_page?(related.to_s.pluralize)
    else
      @lead_status_total = { :all => Lead.my.count, :other => 0 }
      Setting.lead_status.each do |key|
        @lead_status_total[key] = Lead.my.where(:status => key.to_s).count
        @lead_status_total[:other] -= @lead_status_total[key]
      end
      @lead_status_total[:other] += @lead_status_total[:all]
    end
  end

  #----------------------------------------------------------------------------
  def update_sidebar
    if called_from_index_page?
      get_data_for_sidebar
    else
      get_data_for_sidebar(:campaign)
    end
  end
end
