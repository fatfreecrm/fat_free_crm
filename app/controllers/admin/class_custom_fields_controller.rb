class Admin::ClassCustomFieldsController < Admin::ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :auto_complete, :only => :auto_complete

  # GET /super_tags
  # GET /super_tags.xml                                             AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @super_tags = get_super_tags(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @super_tags }
    end
  end

  # GET /super_tags/1
  # GET /super_tags/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show
    @super_tag = ActsAsTaggableOn::Tag.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @super_tag }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /super_tags/new
  # GET /super_tags/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @super_tag = ActsAsTaggableOn::Tag.new
    @disabled = false

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @super_tag }
    end

  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_not_found(:html, :xml)
  end

  # GET /super_tags/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @super_tag = ActsAsTaggableOn::Tag.find(params[:id])
    @disabled = :disabled

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = ActsAsTaggableOn::Tag.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @super_tag
  end

  # POST /super_tags
  # POST /super_tags.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @super_tag = ActsAsTaggableOn::Tag.new(params[:acts_as_taggable_on_tag])
    @disabled = false

    respond_to do |format|
      if @super_tag.save
        @super_tags = get_super_tags if called_from_index_page?
        format.js   # create.js.rjs
        format.xml  { render :xml => @super_tag, :status => :created, :location => @super_tag }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @super_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /super_tags/1
  # PUT /super_tags/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    @super_tag = ActsAsTaggableOn::Tag.find(params[:id])
    respond_to do |format|
      if @super_tag.update_attributes(params[:acts_as_taggable_on_tag])
        format.js
        format.xml  { head :ok }
      else
        format.js
        format.xml  { render :xml => @super_tag.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /super_tags/1
  # DELETE /super_tags/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @super_tag = ActsAsTaggableOn::Tag.find(params[:id])
    @super_tag.destroy if @super_tag
    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # GET /super_tags/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @super_tags = get_super_tags(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @super_tags.to_xml }
    end
  end

  # POST /super_tags/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :auto_complete, :only => :auto_complete

  # GET /super_tags/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel] == "true"
      @per_page = @current_user.pref[:super_tags_per_page] || ActsAsTaggableOn::Tag.per_page
      @outline  = @current_user.pref[:super_tags_outline]  || ActsAsTaggableOn::Tag.outline
      @sort_by  = @current_user.pref[:super_tags_sort_by]  || ActsAsTaggableOn::Tag.sort_by
      @sort_by  = ActsAsTaggableOn::Tag::SORT_BY.invert[@sort_by]
    end
  end

  # POST /super_tags/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:super_tags_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:super_tags_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:super_tags_sort_by]  = ActsAsTaggableOn::Tag::SORT_BY[params[:sort_by]] if params[:sort_by]
    @super_tags = get_super_tags(:page => 1) # Start one the first page.

    render :action => :index
  end

  private
  #----------------------------------------------------------------------------
  def get_super_tags(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.pref[:super_tags_sort_by] || ActsAsTaggableOn::Tag.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.pref[:super_tags_per_page]
    }

    # Call :get_super_tags hook and return its output if any.
    super_tags = hook(:get_super_tags, self, :records => records, :pages => pages)
    return super_tags.last unless super_tags.empty?

    # Default processing if no :get_super_tags hooks are present.
    if current_query.blank?
      ActsAsTaggableOn::Tag.find(:all)
    else
      ActsAsTaggableOn::Tag.search(current_query)
    end.paginate(pages)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        @super_tags = get_super_tags
        if @super_tags.blank?
          @super_tags = get_super_tags(:page => current_page - 1) if current_page > 1
          render :action => :index and return
        end
      else
        self.current_page = 1
      end
      # At this point render destroy.js.rjs
    else
      self.current_page = 1
      flash[:notice] = "#{@super_tag.name} has beed deleted."
      redirect_to(admin_super_tags_path)
    end
  end
end
