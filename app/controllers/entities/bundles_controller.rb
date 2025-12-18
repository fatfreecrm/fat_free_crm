# frozen_string_literal: true

class BundlesController < EntitiesController
  before_action :get_data_for_sidebar, only: :index

  # GET /bundles
  #----------------------------------------------------------------------------
  def index
    @bundles = get_bundles(page: page_param, per_page: per_page_param)

    respond_with @bundles do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @bundles }
    end
  end

  # GET /bundles/1
  # AJAX /bundles/1
  #----------------------------------------------------------------------------
  def show
    @comment = Comment.new
    @timeline = timeline(@bundle)
    @samples = @bundle.samples.order(created_at: :desc)
    respond_with(@bundle)
  end

  # GET /bundles/new
  #----------------------------------------------------------------------------
  def new
    @bundle.attributes = { user: current_user, access: Setting.default_access }

    respond_with(@bundle)
  end

  # GET /bundles/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @previous = Bundle.my(current_user).find_by_id(detect_previous_id) || detect_previous_id if detect_previous_id

    respond_with(@bundle)
  end

  # POST /bundles
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]

    respond_with(@bundle) do |_format|
      if @bundle.save
        @bundle.add_comment_by_user(@comment_body, current_user)
        @bundles = get_bundles
        get_data_for_sidebar
      end
    end
  end

  # PUT /bundles/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@bundle) do |_format|
      @bundle.access = params[:bundle][:access] if params[:bundle][:access]
      get_data_for_sidebar if @bundle.update(resource_params)
    end
  end

  # DELETE /bundles/1
  #----------------------------------------------------------------------------
  def destroy
    @bundle.destroy

    respond_with(@bundle) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # GET /bundles/1/samples                                                AJAX
  #----------------------------------------------------------------------------
  def samples
    @samples = @bundle.samples.order(created_at: :desc)
  end

  # GET /bundles/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:bundles_per_page] = per_page_param if per_page_param
    current_user.pref[:bundles_sort_by]  = Bundle.sort_by_map[params[:sort_by]] if params[:sort_by]
    @bundles = get_bundles(page: 1, per_page: per_page_param)
    set_options

    respond_with(@bundles) do |format|
      format.js { render :index }
    end
  end

  # POST /bundles/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:bundles_filter] = params[:location]
    @bundles = get_bundles(page: 1, per_page: per_page_param)

    respond_with(@bundles) do |format|
      format.js { render :index }
    end
  end

  private

  #----------------------------------------------------------------------------
  alias get_bundles get_list_of_records

  #----------------------------------------------------------------------------
  def list_includes
    %i[samples user tags].freeze
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @bundles = get_bundles
      get_data_for_sidebar
      if @bundles.empty?
        @bundles = get_bundles(page: current_page - 1) if current_page > 1
        render(:index) && return
      end
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @bundle.name)
      redirect_to bundles_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @bundle_location_total = HashWithIndifferentAccess[
      Bundle.my(current_user).distinct.pluck(:location).compact.map do |loc|
        [loc, Bundle.my(current_user).where(location: loc).count]
      end
    ]
    @bundle_location_total[:all] = Bundle.my(current_user).count
    @bundle_location_total[:other] = Bundle.my(current_user).where(location: [nil, '']).count
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_bundles_controller, self)
end
