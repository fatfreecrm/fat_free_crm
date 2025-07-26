class ProductsController < EntitiesController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  before_action :load_settings
  before_action :get_data_for_sidebar, only: :index
  before_action :set_params, only: %i[index redraw filter]

  # GET /products
  def index
    @products = get_products(page: page_param, per_page: per_page_param)

    respond_with @products do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @products }
    end
    @products = Product.all
  end

  # GET /products/1
  def show
    @comment = Comment.new
    @timeline = timeline(@product)
    respond_with(@product)
  end

  # GET /products/new
  def new
    # @product.attributes = { user: current_user }

    # if params[:related]
    #   model, id = params[:related].split('_')
    #   if related = model.classify.constantize.my(current_user).find_by_id(id)
    #     instance_variable_set("@#{model}", related)
    #   else
    #     respond_to_related_not_found(model) && return
    #   end
    # end

    respond_with(@product)
  end

  # GET /products/1/edit
  def edit
    # @previous = product.my(current_user).find_by_id(detect_previous_id) || detect_previous_id if detect_previous_id

    respond_with(@product)
  end

  # POST /products
  def create
    @product = Product.new(product_params)
    # @comment_body = params[:comment_body]
    respond_with(@product) do |_format|
      if @product.save
        # @product.add_comment_by_user(@comment_body, current_user)
        if called_from_index_page?
          @products = get_products
          get_data_for_sidebar
        end
      end
    end
  end

  # PATCH/PUT /products/1
  def update
    respond_with(@product) do |_format|
      if @product.update(product_params)
        if called_from_index_page?
          get_data_for_sidebar
        end
      end
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy

    respond_with(@product) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /products/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # POST /products/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /products/auto_complete/query                                AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /products/redraw                                              AJAX
  #----------------------------------------------------------------------------
  def redraw
    @products = get_products(page: 1, per_page: per_page_param)
    set_options # Refresh options

    respond_with(@products) do |format|
      format.js { render :index }
    end
  end

  # POST /products/filter                                             AJAX
  #----------------------------------------------------------------------------
  def filter
    @products = get_products(page: 1, per_page: per_page_param)
    respond_with(@products) do |format|
      format.js { render :index }
    end
  end
  #----------------------------------------------------------------------------
  def list_includes
    %i[user tags].freeze
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        get_data_for_sidebar
        @products = get_products
        if @products.blank?
          @products = get_products(page: current_page - 1) if current_page > 1
          render(:index) && return
        end
      else # Called from related asset.
        self.current_page = 1
      end
      # At this point render destroy.js
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @product.name)
      redirect_to products_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar(related = false)
    if related
      instance_variable_set("@#{related}", @product.send(related)) if called_from_landing_page?(related.to_s.pluralize)
    else
      # @product_stage_total = HashWithIndifferentAccess[
      #                            all: product.my(current_user).count,
      #                            other: 0
      # ]
      stages = []
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:name, :sku, :description, :image_url, :url, :gtin, :brand)
  end

  def order_by_attributes(scope, order)
    scope.order(order)
  end

  #----------------------------------------------------------------------------
  alias get_products get_list_of_records


  #----------------------------------------------------------------------------
  def load_settings
    # @stage = Setting.unroll(:product_stage)
  end

  #----------------------------------------------------------------------------
  def set_params
    current_user.pref[:products_per_page] = per_page_param if per_page_param
    current_user.pref[:products_sort_by]  = product.sort_by_map[params[:sort_by]] if params[:sort_by]
    # session[:products_filter] = params[:stage] if params[:stage]
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_products_controller, self)
end
