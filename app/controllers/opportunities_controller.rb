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

class OpportunitiesController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :load_settings
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_params, :only => [:index, :redraw, :filter]
  after_filter  :update_recently_viewed, :only => :show

  # GET /opportunities
  # GET /opportunities.xml
  #----------------------------------------------------------------------------
  def index
    @opportunities = get_opportunities(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @opportunities }
      format.xls  { send_data @opportunities.to_xls, :type => :xls }
      format.csv  { send_data @opportunities.to_csv, :type => :csv }
      format.rss  { render "common/index.rss.builder" }
      format.atom { render "common/index.atom.builder" }
    end
  end

  # GET /opportunities/1
  # GET /opportunities/1.xml                                               HTML
  #----------------------------------------------------------------------------
  def show
    @opportunity = Opportunity.my.find(params[:id])
    @comment = Comment.new

    @timeline = Timeline.find(@opportunity)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @opportunity }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /opportunities/new
  # GET /opportunities/new.xml                                             AJAX
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

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @opportunity }
    end

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

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @opportunity
  end

  # POST /opportunities
  # POST /opportunities.xml                                                AJAX
  #----------------------------------------------------------------------------
  def create
    @opportunity = Opportunity.new(params[:opportunity])

    respond_to do |format|
      if @opportunity.save_with_account_and_permissions(params)
        if called_from_index_page?
          @opportunities = get_opportunities
          get_data_for_sidebar
        elsif called_from_landing_page?(:accounts)
          get_data_for_sidebar(:account)
        elsif called_from_landing_page?(:campaigns)
          get_data_for_sidebar(:campaign)
        end
        format.js   # create.js.rjs
        format.xml  { render :xml => @opportunity, :status => :created, :location => @opportunity }
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
        format.js   # create.js.rjs
        format.xml  { render :xml => @opportunity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /opportunities/1
  # PUT /opportunities/1.xml                                               AJAX
  #----------------------------------------------------------------------------
  def update
    @opportunity = Opportunity.my.find(params[:id])

    respond_to do |format|
      if @opportunity.update_with_account_and_permissions(params)
        if called_from_index_page?
          get_data_for_sidebar
        elsif called_from_landing_page?(:accounts)
          get_data_for_sidebar(:account)
        elsif called_from_landing_page?(:campaigns)
          get_data_for_sidebar(:campaign)
        end
        format.js
        format.xml  { head :ok }
      else
        @users = User.except(@current_user)
        @accounts = Account.my.order("name")
        if @opportunity.account
          @account = Account.find(@opportunity.account.id)
        else
          @account = Account.new(:user => @current_user)
        end
        format.js
        format.xml  { render :xml => @opportunity.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /opportunities/1
  # DELETE /opportunities/1.xml                                   HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @opportunity = Opportunity.my.find(params[:id])
    if called_from_landing_page?(:accounts)
      @account = @opportunity.account   # Reload related account if any.
    elsif called_from_landing_page?(:campaigns)
      @campaign = @opportunity.campaign # Reload related campaign if any.
    end
    @opportunity.destroy if @opportunity

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # PUT /opportunities/1/attach
  # PUT /opportunities/1/attach.xml                                        AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :attach

  # POST /opportunities/1/discard
  # POST /opportunities/1/discard.xml                                      AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :discard

  # POST /opportunities/auto_complete/query                                AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /opportunities/search/query                                        AJAX
  #----------------------------------------------------------------------------
  def search
    @opportunities = get_opportunities(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :index }
      format.xml  { render :xml => @opportunities.to_xml }
    end
  end

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
