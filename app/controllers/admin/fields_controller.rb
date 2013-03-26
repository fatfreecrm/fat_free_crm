# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::FieldsController < Admin::ApplicationController
  before_filter "set_current_tab('admin/fields')", :only => [ :index ]

  load_resource :except => [:create, :subform]

  # GET /fields
  # GET /fields.xml                                                      HTML
  #----------------------------------------------------------------------------
  def index
  end

  # GET /fields/1
  # GET /fields/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show
    respond_with(@field)
  end

  # GET /fields/new
  # GET /fields/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @field = Field.new
    respond_with(@field)
  end

  # GET /fields/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @field = Field.find(params[:id])
    respond_with(@field)    
  end

  # POST /fields
  # POST /fields.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    as = params[:field][:as]
    @field = 
      if as =~ /pair/
        CustomFieldPair.create_pair(params).first
      elsif as.present?
        klass = Field.lookup_class(as).classify.constantize
        klass.create(params[:field])
      else
        Field.new(params[:field]).tap(&:valid?)
      end

    respond_with(@field)

  end

  # PUT /fields/1
  # PUT /fields/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    if (params[:field][:as] =~ /pair/)
      @field = CustomFieldPair.update_pair(params).first
    else
      @field = Field.find(params[:id])
      @field.update_attributes(params[:field])
    end

    respond_with(@field)
  end

  # DELETE /fields/1
  # DELETE /fields/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @field = Field.find(params[:id])
    @field.destroy

    respond_with(@field)
  end

  # POST /fields/sort
  #----------------------------------------------------------------------------
  def sort
    field_group_id = params[:field_group_id].to_i
    field_ids = params["fields_field_group_#{field_group_id}"] || []

    field_ids.each_with_index do |id, index|
      Field.update_all({:position => index+1, :field_group_id => field_group_id}, {:id => id})
    end

    render :nothing => true
  end
  
  # GET /fields/subform
  #----------------------------------------------------------------------------
  def subform
    field = params[:field]
    as = field[:as]

    @field = if (id = field[:id]).present?
        Field.find(id).tap{|f| f.as = as}
      else
        field_group_id = field[:field_group_id]
        klass = Field.lookup_class(as).classify.constantize
        klass.new(:field_group_id => field_group_id, :as => as)
      end

    respond_with(@field) do |format|
      format.html { render :partial => 'admin/fields/subform' }
    end  
  end
  
end
