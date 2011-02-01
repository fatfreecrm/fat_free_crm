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

class CampaignsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :attach, :only => :attach
  before_filter :discard, :only => :discard
  before_filter :auto_complete, :only => :auto_complete
  after_filter  :update_recently_viewed, :only => :show

  # GET /campaigns
  # GET /campaigns.xml                                            AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @campaigns = get_campaigns(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @campaigns }
    end
  end

  # GET /campaigns/1
  # GET /campaigns/1.xml                                                   HTML
  #----------------------------------------------------------------------------
  def show
    @campaign = Campaign.my(@current_user).find(params[:id])
    @stage = Setting.unroll(:opportunity_stage)
    @comment = Comment.new

    @timeline = Timeline.find(@campaign)

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @campaign }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /campaigns/new
  # GET /campaigns/new.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def new
    @campaign = Campaign.new(:user => @current_user, :access => Setting.default_access)
    @users = User.except(@current_user).active.all
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @campaign }
    end
  end

  # GET /campaigns/1/edit                                                  AJAX
  #----------------------------------------------------------------------------
  def edit
    @campaign = Campaign.my(@current_user).find(params[:id])
    @users = User.except(@current_user).active.all
    if params[:previous] =~ /(\d+)\z/
      @previous = Campaign.my(@current_user).find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @campaign
  end

  # POST /campaigns
  # POST /campaigns.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def create
    @campaign = Campaign.new(params[:campaign])
    @users = User.except(@current_user).active.all

    respond_to do |format|
      if @campaign.save_with_permissions(params[:users])
        @campaigns = get_campaigns
        get_data_for_sidebar
        format.js   # create.js.rjs
        format.xml  { render :xml => @campaign, :status => :created, :location => @campaign }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /campaigns/1
  # PUT /campaigns/1.xml                                                   AJAX
  #----------------------------------------------------------------------------
  def update
    @campaign = Campaign.my(@current_user).find(params[:id])

    respond_to do |format|
      if @campaign.update_with_permissions(params[:campaign], params[:users])
        get_data_for_sidebar if called_from_index_page?
        format.js
        format.xml  { head :ok }
      else
        @users = User.except(@current_user).active.all # Need it to redraw [Edit Campaign] form.
        format.js
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.xml                                       HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @campaign = Campaign.my(@current_user).find(params[:id])
    @campaign.destroy if @campaign

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # GET /campaigns/search/query                                           AJAX
  #----------------------------------------------------------------------------
  def search
    @campaigns = get_campaigns(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @campaigns.to_xml }
    end
  end

  # PUT /campaigns/1/attach
  # PUT /campaigns/1/attach.xml                                            AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :attach, :only => :attach

  # PUT /campaigns/1/discard
  # PUT /campaigns/1/discard.xml                                           AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :discard, :only => :discard

  # POST /campaigns/auto_complete/query                                    AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :auto_complete, :only => :auto_complete

  # GET /campaigns/options                                                 AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:campaigns_per_page] || Campaign.per_page
      @outline  = @current_user.pref[:campaigns_outline]  || Campaign.outline
      @sort_by  = @current_user.pref[:campaigns_sort_by]  || Campaign.sort_by
    end
  end

  # POST /campaigns/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:campaigns_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:campaigns_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:campaigns_sort_by]  = Campaign::sort_by_map[params[:sort_by]] if params[:sort_by]
    @campaigns = get_campaigns(:page => 1)
    render :action => :index
  end

  # POST /campaigns/filter                                                 AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_campaign_status] = params[:status]
    @campaigns = get_campaigns(:page => 1)
    render :action => :index
  end

  private
  #----------------------------------------------------------------------------
  def get_campaigns(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.pref[:campaigns_sort_by] || Campaign.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.pref[:campaigns_per_page]
    }

    # Call :get_campaigns hook and return its output if any.
    campaigns = hook(:get_campaigns, self, :records => records, :pages => pages)
    return campaigns.last unless campaigns.empty?

    # Default processing if no :get_campaigns hooks are present.
    if session[:filter_by_campaign_status]
      filtered = session[:filter_by_campaign_status].split(",")
      current_query.blank? ? Campaign.my(records).only(filtered) : Campaign.my(records).only(filtered).search(current_query)
    else
      current_query.blank? ? Campaign.my(records) : Campaign.my(records).search(current_query)
    end.paginate(pages)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      get_data_for_sidebar
      @campaigns = get_campaigns
      if @campaigns.blank?
        @campaigns = get_campaigns(:page => current_page - 1) if current_page > 1
        render :action => :index and return
      end
      # At this point render destroy.js.rjs
    else # :html request
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @campaign.name)
      redirect_to(campaigns_path)
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @campaign_status_total = { :all => Campaign.my(@current_user).count, :other => 0 }
    Setting.campaign_status.each do |key|
      @campaign_status_total[key] = Campaign.my(@current_user).count(:conditions => [ "status=?", key.to_s ])
      @campaign_status_total[:other] -= @campaign_status_total[key]
    end
    @campaign_status_total[:other] += @campaign_status_total[:all]
  end

end
