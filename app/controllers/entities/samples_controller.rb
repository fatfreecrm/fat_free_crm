# frozen_string_literal: true

class SamplesController < EntitiesController
  before_action :get_data_for_sidebar, only: :index

  # GET /samples
  #----------------------------------------------------------------------------
  def index
    @samples = get_samples(page: page_param, per_page: per_page_param)

    respond_with @samples do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @samples }
    end
  end

  # GET /samples/1
  # AJAX /samples/1
  #----------------------------------------------------------------------------
  def show
    @comment = Comment.new
    @timeline = timeline(@sample)
    respond_with(@sample)
  end

  # GET /samples/new
  #----------------------------------------------------------------------------
  def new
    @sample.attributes = { user: current_user, access: Setting.default_access }
    @bundles = Bundle.my(current_user).by_name

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@sample)
  end

  # GET /samples/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @bundles = Bundle.my(current_user).by_name
    @previous = Sample.my(current_user).find_by_id(detect_previous_id) || detect_previous_id if detect_previous_id

    respond_with(@sample)
  end

  # POST /samples
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    @bundles = Bundle.my(current_user).by_name

    respond_with(@sample) do |_format|
      if @sample.save
        @sample.add_comment_by_user(@comment_body, current_user)
        @samples = get_samples
        get_data_for_sidebar
      end
    end
  end

  # PUT /samples/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@sample) do |_format|
      @sample.access = params[:sample][:access] if params[:sample][:access]
      get_data_for_sidebar if @sample.update(resource_params)
    end
  end

  # DELETE /samples/1
  #----------------------------------------------------------------------------
  def destroy
    @sample.destroy

    respond_with(@sample) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /samples/1/checkout
  #----------------------------------------------------------------------------
  def checkout
    @sample.checkout!(current_user)
    respond_with(@sample) do |format|
      format.html { redirect_to @sample, notice: t(:sample_checked_out) }
      format.js
    end
  end

  # PUT /samples/1/checkin
  #----------------------------------------------------------------------------
  def checkin
    @sample.checkin!
    respond_with(@sample) do |format|
      format.html { redirect_to @sample, notice: t(:sample_checked_in) }
      format.js
    end
  end

  # GET /samples/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:samples_per_page] = per_page_param if per_page_param
    current_user.pref[:samples_sort_by]  = Sample.sort_by_map[params[:sort_by]] if params[:sort_by]
    @samples = get_samples(page: 1, per_page: per_page_param)
    set_options

    respond_with(@samples) do |format|
      format.js { render :index }
    end
  end

  # POST /samples/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:samples_filter] = params[:status]
    @samples = get_samples(page: 1, per_page: per_page_param)

    respond_with(@samples) do |format|
      format.js { render :index }
    end
  end

  private

  #----------------------------------------------------------------------------
  alias get_samples get_list_of_records

  #----------------------------------------------------------------------------
  def list_includes
    %i[bundle user tags].freeze
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @samples = get_samples
      get_data_for_sidebar
      if @samples.empty?
        @samples = get_samples(page: current_page - 1) if current_page > 1
        render(:index) && return
      end
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @sample.name)
      redirect_to samples_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @sample_status_total = HashWithIndifferentAccess[
      %w[available checked_out reserved discontinued].map do |status|
        [status, Sample.my(current_user).where(status: status).count]
      end
    ]
    @sample_status_total[:all] = Sample.my(current_user).count
    @sample_status_total[:fire_sale] = Sample.my(current_user).fire_sale.count
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_samples_controller, self)
end
