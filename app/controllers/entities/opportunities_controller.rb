# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class OpportunitiesController < EntitiesController
  before_action :load_settings
  before_action :get_data_for_sidebar, only: :index
  before_action :set_params, only: %i[index redraw filter]

  # GET /opportunities
  #----------------------------------------------------------------------------
  def index
    @opportunities = get_opportunities(page: page_param, per_page: per_page_param)

    respond_with @opportunities do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @opportunities }
    end
  end

  # GET /opportunities/1
  # AJAX /opportunities/1
  #----------------------------------------------------------------------------
  def show
    @comment = Comment.new
    @timeline = timeline(@opportunity)
    respond_with(@opportunity)
  end

  # GET /opportunities/new
  #----------------------------------------------------------------------------
  def new
    @opportunity.attributes = { user: current_user, stage: Opportunity.default_stage, access: Setting.default_access, assigned_to: nil }
    @account     = Account.new(user: current_user, access: Setting.default_access)
    @accounts    = Account.my(current_user).order('name')

    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.my(current_user).find_by_id(id)
        instance_variable_set("@#{model}", related)
        @account = related.account if related.respond_to?(:account) && !related.account.nil?
        @campaign = related.campaign if related.respond_to?(:campaign)
      else
        respond_to_related_not_found(model) && return
      end
    end

    respond_with(@opportunity)
  end

  # GET /opportunities/1/edit                                              AJAX
  #----------------------------------------------------------------------------
  def edit
    @account  = @opportunity.account || Account.new(user: current_user)
    @accounts = Account.my(current_user).order('name')

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Opportunity.my(current_user).find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@opportunity)
  end

  # POST /opportunities
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    respond_with(@opportunity) do |_format|
      if @opportunity.save_with_account_and_permissions(params.permit!)
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
        @accounts = Account.my(current_user).order('name')
        @account = if params[:account][:id].blank?
                     if request.referer =~ /\/accounts\/(\d+)\z/
                       Account.find(Regexp.last_match[1]) # related account
                     else
                       Account.new(user: current_user)
                     end
                   else
                     Account.find(params[:account][:id])
                   end
        @contact = Contact.find(params[:contact]) unless params[:contact].blank?
        @campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
      end
    end
  end

  # PUT /opportunities/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@opportunity) do |_format|
      if @opportunity.update_with_account_and_permissions(params.permit!)
        if called_from_index_page?
          get_data_for_sidebar
        elsif called_from_landing_page?(:accounts)
          get_data_for_sidebar(:account)
        elsif called_from_landing_page?(:campaigns)
          get_data_for_sidebar(:campaign)
        end
      else
        @accounts = Account.my(current_user).order('name')
        @account = if @opportunity.account
                     Account.find(@opportunity.account.id)
                   else
                     Account.new(user: current_user)
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

  # GET /opportunities/redraw                                              AJAX
  #----------------------------------------------------------------------------
  def redraw
    @opportunities = get_opportunities(page: 1, per_page: per_page_param)
    set_options # Refresh options

    respond_with(@opportunities) do |format|
      format.js { render :index }
    end
  end

  # POST /opportunities/filter                                             AJAX
  #----------------------------------------------------------------------------
  def filter
    @opportunities = get_opportunities(page: 1, per_page: per_page_param)
    respond_with(@opportunities) do |format|
      format.js { render :index }
    end
  end

  private

  def order_by_attributes(scope, order)
    scope.weighted_sort.order(order)
  end

  #----------------------------------------------------------------------------
  alias get_opportunities get_list_of_records

  #----------------------------------------------------------------------------
  def list_includes
    %i[account user tags].freeze
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        get_data_for_sidebar
        @opportunities = get_opportunities
        if @opportunities.blank?
          @opportunities = get_opportunities(page: current_page - 1) if current_page > 1
          render(:index) && return
        end
      else # Called from related asset.
        self.current_page = 1
      end
      # At this point render destroy.js
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
      @opportunity_stage_total = HashWithIndifferentAccess[
                                 all: Opportunity.my(current_user).count,
                                 other: 0
      ]
      stages = []
      @stage.each do |_value, key|
        stages << key
        @opportunity_stage_total[key] = 0
      end

      stage_counts = Opportunity.my(current_user).where(stage: stages).group(:stage).count
      stage_counts.each do |key, total|
        @opportunity_stage_total[key.to_sym] = total
        @opportunity_stage_total[:other] -= total
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
    current_user.pref[:opportunities_per_page] = per_page_param if per_page_param
    current_user.pref[:opportunities_sort_by]  = Opportunity.sort_by_map[params[:sort_by]] if params[:sort_by]
    session[:opportunities_filter] = params[:stage] if params[:stage]
  end
end
