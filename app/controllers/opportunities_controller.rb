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

class OpportunitiesController < BaseController
  before_filter :load_settings
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_params, :only => [:index, :redraw, :filter]

  # GET /opportunities
  #----------------------------------------------------------------------------
  def index
    @opportunities = get_opportunities(:page => params[:page])
    respond_with(@opportunities)
  end

  # GET /opportunities/1
  #----------------------------------------------------------------------------
  def show
    @opportunity = Opportunity.my.find(params[:id])

    respond_with(@opportunity) do |format|
      format.html do
        @comment = Comment.new
        @timeline = timeline(@opportunity)
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :json, :xml)
  end

  # GET /opportunities/new
  #----------------------------------------------------------------------------
  def new
    @opportunity = Opportunity.new(:user => @current_user, :stage => "prospecting", :access => Setting.default_access)
    @users       = User.except(@current_user)
    @account     = Account.new(:user => @current_user)
    @accounts    = Account.my.order("name")
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.my.find(id))
    end
    respond_with(@opportunity)

  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /opportunities/1/edit                                              AJAX
  #----------------------------------------------------------------------------
  def edit
    @opportunity = Opportunity.my.find(params[:id])
    @users = User.except(@current_user)
    @account  = @opportunity.account || Account.new(:user => @current_user)
    @accounts = Account.my.order("name")
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Opportunity.my.find($1)
    end
    respond_with(@opportunity)

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @opportunity
  end

  # POST /opportunities
  #----------------------------------------------------------------------------
  def create
    @opportunity = Opportunity.new(params[:opportunity])

    respond_with(@opportunity) do |format|
      if @opportunity.save_with_account_and_permissions(params)
        if called_from_index_page?
          @opportunities = get_opportunities
          get_data_for_sidebar
        elsif called_from_landing_page?(:accounts)
          get_data_for_sidebar(:account)
        elsif called_from_landing_page?(:campaigns)
          get_data_for_sidebar(:campaign)
        end
      else
        @users = User.except(@current_user)
        @accounts = Account.my.order("name")
        unless params[:account][:id].blank?
          @account = Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(.+)$/
            @account = Account.find($1) # related account
          else
            @account = Account.new(:user => @current_user)
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
    @opportunity = Opportunity.my.find(params[:id])

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
        @users = User.except(@current_user)
        @accounts = Account.my.order("name")
        if @opportunity.account
          @account = Account.find(@opportunity.account.id)
        else
          @account = Account.new(:user => @current_user)
        end
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /opportunities/1
  #----------------------------------------------------------------------------
  def destroy
    @opportunity = Opportunity.my.find(params[:id])
    if called_from_landing_page?(:accounts)
      @account = @opportunity.account   # Reload related account if any.
    elsif called_from_landing_page?(:campaigns)
      @campaign = @opportunity.campaign # Reload related campaign if any.
    end
    @opportunity.destroy if @opportunity

    respond_with(@opportunity) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  # PUT /opportunities/1/attach
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :attach

  # POST /opportunities/1/discard
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :discard

  # POST /opportunities/auto_complete/query                                AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /opportunities/options                                             AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:opportunities_per_page] || Opportunity.per_page
      @outline  = @current_user.pref[:opportunities_outline]  || Opportunity.outline
      @sort_by  = @current_user.pref[:opportunities_sort_by]  || Opportunity.sort_by
    end
  end

  # GET /opportunities/contacts                                            AJAX
  #----------------------------------------------------------------------------
  def contacts
    @opportunity = Opportunity.my.find(params[:id])
  end

  # POST /opportunities/redraw                                             AJAX
  #----------------------------------------------------------------------------
  def redraw
    @opportunities = get_opportunities(:page => 1)
    render :index
  end

  # POST /opportunities/filter                                             AJAX
  #----------------------------------------------------------------------------
  def filter
    @opportunities = get_opportunities(:page => 1)
    render :index
  end

  private
  #----------------------------------------------------------------------------
  def get_opportunities(options = {})
    get_list_of_records(Opportunity, options.merge!(:filter => :filter_by_opportunity_stage))
  end

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

  def set_params
    @current_user.pref[:opportunities_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:opportunities_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:opportunities_sort_by]  = Opportunity::sort_by_map[params[:sort_by]] if params[:sort_by]
    session[:filter_by_opportunity_stage] = params[:stage] if params[:stage]
  end
end
