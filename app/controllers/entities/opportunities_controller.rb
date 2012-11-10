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

class OpportunitiesController < EntitiesController
  before_filter :load_settings
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_params, :only => [ :index, :redraw, :filter ]

  # GET /opportunities
  #----------------------------------------------------------------------------
  def index
    @opportunities = get_opportunities(:page => params[:page], :per_page => params[:per_page])

    respond_with @opportunities do |format|
      format.xls { render :layout => 'header' }
    end
  end

  # GET /opportunities/1
  #----------------------------------------------------------------------------
  def show
    respond_with(@opportunity) do |format|
      format.html do
        @comment = Comment.new
        @timeline = timeline(@opportunity)
      end
    end
  end

  # GET /opportunities/new
  #----------------------------------------------------------------------------
  def new
    @opportunity.attributes = {:user => current_user, :stage => "prospecting", :access => Setting.default_access, :assigned_to => nil}
    @users       = User.except(current_user)
    @account     = Account.new(:user => current_user, :access => Setting.default_access)
    @accounts    = Account.my.order('name')

    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end

    respond_with(@opportunity)
  end

  # GET /opportunities/1/edit                                              AJAX
  #----------------------------------------------------------------------------
  def edit
    @users = User.except(current_user)
    @account  = @opportunity.account || Account.new(:user => current_user)
    @accounts = Account.my.order('name')

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Opportunity.my.find_by_id($1) || $1.to_i
    end

    respond_with(@opportunity)
  end

  # POST /opportunities
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    respond_with(@opportunity) do |format|
      if @opportunity.save_with_account_and_permissions(params)
        @opportunity.add_comment_by_user(@comment_body, current_user)
        if called_from_index_page?
          @opportunities = get_opportunities
          get_data_for_sidebar
        elsif called_from_landing_page?(:accounts)
          get_data_for_sidebar(:account)
        elsif called_from_landing_page?(:campaigns)
          get_data_for_sidebar(:campaign)
        end
      else
        @users = User.except(current_user)
        @accounts = Account.my.order('name')
        unless params[:account][:id].blank?
          @account = Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(.+)$/
            @account = Account.find($1) # related account
          else
            @account = Account.new(:user => current_user)
          end
        end
        @contact = Contact.find(params[:contact]) unless params[:contact].blank?
        @campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
      end
    end
  end

  # PUT /opportunities/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@opportunity) do |format|
      if @opportunity.update_with_account_and_permissions(params)
        if called_from_index_page?
          get_data_for_sidebar
        elsif called_from_landing_page?(:accounts)
          get_data_for_sidebar(:account)
        elsif called_from_landing_page?(:campaigns)
          get_data_for_sidebar(:campaign)
        end
      else
        @users = User.except(current_user)
        @accounts = Account.my.order('name')
        if @opportunity.account
          @account = Account.find(@opportunity.account.id)
        else
          @account = Account.new(:user => current_user)
        end
      end
    end
  end

  # DELETE /opportunities/1
  #----------------------------------------------------------------------------
  def destroy
    if called_from_landing_page?(:accounts)
      @account = @opportunity.account   # Reload related account if any.
    elsif called_from_landing_page?(:campaigns)
      @campaign = @opportunity.campaign # Reload related campaign if any.
    end
    @opportunity.destroy

    respond_with(@opportunity) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /opportunities/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # POST /opportunities/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /opportunities/auto_complete/query                                AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # POST /opportunities/redraw                                             AJAX
  #----------------------------------------------------------------------------
  def redraw
    @opportunities = get_opportunities(:page => 1, :per_page => params[:per_page])
    set_options # Refresh options
    render :index
  end

  # POST /opportunities/filter                                             AJAX
  #----------------------------------------------------------------------------
  def filter
    @opportunities = get_opportunities(:page => 1, :per_page => params[:per_page])
    render :index
  end

private

  #----------------------------------------------------------------------------
  alias :get_opportunities :get_list_of_records

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        get_data_for_sidebar
        @opportunities = get_opportunities
        if @opportunities.blank?
          @opportunities = get_opportunities(:page => current_page - 1) if current_page > 1
          render :index and return
        end
      else # Called from related asset.
        self.current_page = 1
      end
      # At this point render destroy.js.rjs
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @opportunity.name)
      redirect_to opportunities_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar(related = false)
    if related
      instance_variable_set("@#{related}", @opportunity.send(related)) if called_from_landing_page?(related.to_s.pluralize)
    else
      @opportunity_stage_total = { :all => Opportunity.my.count, :other => 0 }
      @stage.each do |value, key|
        @opportunity_stage_total[key] = Opportunity.my.where(:stage => key.to_s).count
        @opportunity_stage_total[:other] -= @opportunity_stage_total[key]
      end
      @opportunity_stage_total[:other] += @opportunity_stage_total[:all]
    end
  end

  #----------------------------------------------------------------------------
  def load_settings
    @stage = Setting.unroll(:opportunity_stage)
  end

  #----------------------------------------------------------------------------
  def set_params
    current_user.pref[:opportunities_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:opportunities_outline]  = params[:outline]  if params[:outline]
    current_user.pref[:opportunities_sort_by]  = Opportunity::sort_by_map[params[:sort_by]] if params[:sort_by]
    session[:opportunities_filter] = params[:stage] if params[:stage]
  end
end
