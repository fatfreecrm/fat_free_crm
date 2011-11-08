# Fat Free CRM
# Copyright (C) 2008-2009 by Michael Dvorkin
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

class Admin::FieldsController < Admin::ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :auto_complete, :only => :auto_complete

  def sort
    params[:custom_fields].each_with_index do |id, index|
      CustomField.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end


  # GET /custom_fields/1
  # GET /custom_fields/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show
    @custom_field = CustomField.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @custom_field }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /custom_fields/new
  # GET /custom_fields/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @custom_field = CustomField.new(:user => @current_user, :tag_id => params[:tag_id])
    @disabled = false

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @custom_field }
    end

  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_not_found(:html, :xml)
  end

  # GET /custom_fields/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @custom_field = CustomField.find(params[:id])
    @disabled = :disabled

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = CustomField.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @custom_field
  end

  # POST /custom_fields
  # POST /custom_fields.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @custom_field = CustomField.new(params[:custom_field])
    @disabled = false

    respond_to do |format|
      if @custom_field.save
        @custom_fields = if params[:custom_field][:tag_id]
          ActsAsTaggableOn::Tag.find(params[:custom_field][:tag_id]).custom_fields
        elsif called_from_index_page?
          get_custom_fields
        end
        format.js   # create.js.rjs
        format.xml  { render :xml => @custom_field, :status => :created, :location => @custom_field }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @custom_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /custom_fields/1
  # PUT /custom_fields/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    @custom_field = CustomField.find(params[:id])

    respond_to do |format|
      if @custom_field.update_attributes(params[:custom_field])
        format.js
        format.xml  { head :ok }
      else
        format.js
        format.xml  { render :xml => @custom_field.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /custom_fields/1
  # DELETE /custom_fields/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @custom_field = CustomField.find(params[:id])
    @custom_field.destroy if @custom_field

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # GET /custom_fields/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @custom_fields = get_custom_fields(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @custom_fields.to_xml }
    end
  end

  # POST /custom_fields/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :auto_complete, :only => :auto_complete

  # GET /custom_fields/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel] == "true"
      @per_page = @current_user.pref[:custom_fields_per_page] || CustomField.per_page
      @outline  = @current_user.pref[:custom_fields_outline]  || CustomField.outline
      @sort_by  = @current_user.pref[:custom_fields_sort_by]  || CustomField.sort_by
      @sort_by  = CustomField::SORT_BY.invert[@sort_by]
    end
  end

  # POST /custom_fields/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:custom_fields_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:custom_fields_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:custom_fields_sort_by]  = CustomField::SORT_BY[params[:sort_by]] if params[:sort_by]
    @custom_fields = get_custom_fields(:page => 1) # Start one the first page.

    render :action => :index
  end

  private
  #----------------------------------------------------------------------------
  def get_custom_fields(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.pref[:custom_fields_sort_by] || CustomField.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.pref[:custom_fields_per_page]
    }

    # Call :get_custom_fields hook and return its output if any.
    custom_fields = hook(:get_custom_fields, self, :records => records, :pages => pages)
    return custom_fields.last unless custom_fields.empty?

    # Default processing if no :get_custom_fields hooks are present.
    if current_query.blank?
      CustomField.find(:all)
    else
      CustomField.search(current_query)
    end.paginate(pages)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        @custom_fields = get_custom_fields
        if @custom_fields.blank?
          @custom_fields = get_custom_fields(:page => current_page - 1) if current_page > 1
          render :action => :index and return
        end
      else
        self.current_page = 1
      end
      # At this point render destroy.js.rjs
    else
      self.current_page = 1
      flash[:notice] = "#{@custom_field.field_name} has beed deleted."
      redirect_to(custom_fields_path)
    end
  end
end

