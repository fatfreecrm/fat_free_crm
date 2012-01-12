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

class BaseController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  after_filter  :update_recently_viewed, :only => :show

  respond_to :html, :only => [ :index, :show, :auto_complete ]
  respond_to :js
  respond_to :json, :xml, :except => :edit
  respond_to :atom, :csv, :rss, :xls, :only => :index

  helper_method :search

  # Common auto_complete handler for all core controllers.
  #----------------------------------------------------------------------------
  def auto_complete
    @query = params[:auto_complete_query]
    @auto_complete = hook(:auto_complete, self, :query => @query, :user => @current_user)
    if @auto_complete.empty?
      @auto_complete = klass.my.text_search(@query).limit(10)
    else
      @auto_complete = @auto_complete.last
    end
    session[:auto_complete] = controller_name.to_sym
    respond_to do |format|
      format.any(:js, :html)   { render "shared/auto_complete", :layout => nil }
      format.json { render :json => @auto_complete.inject({}){|h,a| h[a.id] = a.name; h } }
    end
  end

  # Common attach handler for all core controllers.
  #----------------------------------------------------------------------------
  def attach
    model = klass.my.find(params[:id])
    @attachment = params[:assets].classify.constantize.find(params[:asset_id])
    @attached = model.attach!(@attachment)
    @account  = model.reload if model.is_a?(Account)
    @campaign = model.reload if model.is_a?(Campaign)

    respond_to do |format|
      format.js   { render "shared/attach" }
      format.json { render :json => model.reload }
      format.xml  { render :xml => model.reload }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  # Common discard handler for all core controllers.
  #----------------------------------------------------------------------------
  def discard
    model = klass.my.find(params[:id])
    @attachment = params[:attachment].constantize.find(params[:attachment_id])
    model.discard!(@attachment)
    @account  = model.reload if model.is_a?(Account)
    @campaign = model.reload if model.is_a?(Campaign)

    respond_to do |format|
      format.js   { render "shared/discard" }
      format.json { render :json => model.reload }
      format.xml  { render :xml => model.reload }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  def timeline(asset)
    (asset.comments + asset.emails).sort { |x, y| y.created_at <=> x.created_at }
  end

  # Controller instance method that responds to /controlled/tagged/tag request.
  # It stores given tag as current query and redirect to index to display all
  # records tagged with the tag.
  #----------------------------------------------------------------------------
  def tagged
    self.send(:current_query=, "#" << params[:id]) unless params[:id].blank?
    redirect_to :action => "index"
  end

  def field_group
    if @tag = Tag.find_by_name(params[:tag].strip)
      if @field_group = FieldGroup.find_by_tag_id_and_klass_name(@tag.id, klass.to_s)
        @asset = klass.find_by_id(params[:asset_id]) || klass.new
        render 'fields/group' and return
      end
    end
    render :text => ''
  end

  private

  def search
    @search ||= begin
      search = klass.search(params[:q])
      search.build_grouping unless search.groupings.any?
      search
    end
  end

  # Get list of records for a given model class.
  #----------------------------------------------------------------------------
  def get_list_of_records(klass, options = {})
    items = klass.name.tableize
    options[:query] ||= params[:query]                        if params[:query]
    self.current_page = options[:page]                        if options[:page]
    query, tags       = parse_query_and_tags(options[:query]) if options[:query]
    self.current_query = query

    records = {
      :user  => current_user,
      :order => current_user.pref[:"#{items}_sort_by"] || klass.sort_by
    }
    pages = {
      :page     => current_page,
      :per_page => current_user.pref[:"#{items}_per_page"]
    }

    # Call the hook and return its output if any.
    assets = hook(:"get_#{items}", self, :records => records, :pages => pages)
    return assets.last unless assets.empty?

    # Use default processing if no hooks are present. Note that comma-delimited
    # export includes deleted records, and the pagination is enabled only for
    # plain HTTP, Ajax and XML API requests.
    wants = request.format
    filter = session[options[:filter]].to_s.split(',') if options[:filter]

    scope = klass.my(records)
    scope = scope.merge(search.result)
    scope = scope.state(filter)                   if filter.present?
    scope = scope.text_search(query)              if query.present?
    scope = scope.tagged_with(tags, :on => :tags) if tags.present?
    scope = scope.unscoped                        if wants.csv?
    scope = scope.paginate(pages)                 if wants.html? || wants.js? || wants.xml?
    scope
  end
end
