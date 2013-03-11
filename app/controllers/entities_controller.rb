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

class EntitiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :set_view, :only => [ :index, :show, :redraw ]
  
  before_filter :set_options, :only => :index
  before_filter :load_ransack_search, :only => :index

  load_and_authorize_resource

  after_filter :update_recently_viewed, :only => :show

  helper_method :entity, :entities

  # Common attach handler for all core controllers.
  #----------------------------------------------------------------------------
  def attach
    @attachment = params[:assets].classify.constantize.find(params[:asset_id])
    @attached = entity.attach!(@attachment)
    entity.reload

    respond_with(entity)
  end

  # Common discard handler for all core controllers.
  #----------------------------------------------------------------------------
  def discard
    @attachment = params[:attachment].constantize.find(params[:attachment_id])
    entity.discard!(@attachment)
    entity.reload

    respond_with(entity)
  end

  # Common subscribe handler for all core controllers.
  #----------------------------------------------------------------------------
  def subscribe
    entity.subscribed_users += [current_user.id]
    entity.save

    respond_with(entity) do |format|
      format.js { render 'subscription_update' }
    end
  end

  # Common unsubscribe handler for all core controllers.
  #----------------------------------------------------------------------------
  def unsubscribe
    entity.subscribed_users -= [current_user.id]
    entity.save

    respond_with(entity) do |format|
      format.js { render 'subscription_update' }
    end
  end

  # GET /entities/contacts                                                 AJAX
  #----------------------------------------------------------------------------
  def contacts
  end

  # GET /entities/leads                                                    AJAX
  #----------------------------------------------------------------------------
  def leads
  end

  # GET /entities/opportunities                                            AJAX
  #----------------------------------------------------------------------------
  def opportunities
  end

  # GET /entities/versions                                                 AJAX
  #----------------------------------------------------------------------------
  def versions
  end

  #----------------------------------------------------------------------------
  def field_group
    if @tag = Tag.find_by_name(params[:tag].strip)
      if @field_group = FieldGroup.find_by_tag_id_and_klass_name(@tag.id, klass.to_s)
        @asset = klass.find_by_id(params[:asset_id]) || klass.new
        render 'fields/group' and return
      end
    end
    render :text => ''
  end

protected

  #----------------------------------------------------------------------------
  def entity=(entity)
    instance_variable_set("@#{controller_name.singularize}", entity)
  end

  #----------------------------------------------------------------------------
  def entity
    instance_variable_get("@#{controller_name.singularize}")
  end

  #----------------------------------------------------------------------------
  def entities=(entities)
    instance_variable_set("@#{controller_name}", entities)
  end

  #----------------------------------------------------------------------------
  def entities
    instance_variable_get("@#{controller_name}") || klass.my
  end
  
  def set_options
    unless params[:cancel].true?
      klass = controller_name.classify.constantize
      action = params['action']
      @per_page = current_user.pref[:"#{controller_name}_per_page"] || klass.per_page
      @sort_by  = current_user.pref[:"#{controller_name}_sort_by"]  || klass.sort_by
    end
  end

private

  def ransack_search
    @ransack_search ||= load_ransack_search
    @ransack_search.build_sort if @ransack_search.sorts.empty?
    @ransack_search
  end

  # Get list of records for a given model class.
  #----------------------------------------------------------------------------
  def get_list_of_records(options = {})
    options[:query]  ||= params[:query]                        if params[:query]
    self.current_page  = options[:page]                        if options[:page]
    query, tags        = parse_query_and_tags(options[:query])
    self.current_query = query
    advanced_search = params[:q].present?
    wants = request.format

    scope = entities.merge(ransack_search.result(:distinct => true))

    # Get filter from session, unless running an advanced search
    unless advanced_search
      filter = session[:"#{controller_name}_filter"].to_s.split(',')
      scope = scope.state(filter) if filter.present?
    end

    scope = scope.text_search(query)              if query.present?
    scope = scope.tagged_with(tags, :on => :tags) if tags.present?

    # Ignore this order when doing advanced search
    unless advanced_search
      order = current_user.pref[:"#{controller_name}_sort_by"] || klass.sort_by
      scope = scope.order(order)
    end

    @search_results_count = scope.count

    # Pagination is disabled for xls and csv requests
    unless (wants.xls? || wants.csv?)
      per_page = if options[:per_page]
        options[:per_page] == 'all' ? @search_results_count : options[:per_page]
      else
        current_user.pref[:"#{controller_name}_per_page"]
      end
      scope = scope.paginate(:page => current_page, :per_page => per_page)
    end
    
    scope
  end

  #----------------------------------------------------------------------------
  def update_recently_viewed
    entity.versions.create(:event => :view, :whodunnit => PaperTrail.whodunnit)
  end

  # Somewhat simplistic parser that extracts query and hash-prefixed tags from
  # the search string and returns them as two element array, for example:
  #
  # "#real Billy Bones #pirate" => [ "Billy Bones", "real, pirate" ]
  #----------------------------------------------------------------------------
  def parse_query_and_tags(search_string)
    return ['', ''] if search_string.blank?
    query, tags = [], []
    search_string.strip.split(/\s+/).each do |token|
      if token.starts_with?("#")
        tags << token[1 .. -1]
      else
        query << token
      end
    end
    [ query.join(" "), tags.join(", ") ]
  end

  #----------------------------------------------------------------------------
  def timeline(asset)
    (asset.comments + asset.emails).sort { |x, y| y.created_at <=> x.created_at }
  end

  # Sets the current template view for entities in this context
  #----------------------------------------------------------------------------
  def set_view
    if params['view']
      controller = params['controller']
      action = (params['action'] == 'show') ? 'show' : 'index' # create update redraw filter index actions all use index view
      current_user.pref[:"#{controller}_#{action}_view"] = params['view']
    end
  end
end
