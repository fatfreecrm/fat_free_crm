# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::FieldsController < Admin::ApplicationController
  before_action :setup_current_tab, only: [:index]
  load_resource except: %i[create subform]

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
    as = field_params[:as]
    @field =
      if as.match?(/pair/)
        CustomFieldPair.create_pair(params).first
      elsif as.present?
        klass = find_class(Field.lookup_class(as))
        klass.create(field_params)
      else
        Field.new(field_params).tap(&:valid?)
      end

    respond_with(@field)
  end

  # PUT /fields/1
  # PUT /fields/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    if field_params[:as].match?(/pair/)
      @field = CustomFieldPair.update_pair(params).first
    else
      @field = Field.find(params[:id])
      @field.update(field_params)
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
      Field.where(id: id).update_all(position: index + 1, field_group_id: field_group_id)
    end

    render nothing: true
  end

  # GET /fields/subform
  #----------------------------------------------------------------------------
  def subform
    field = field_params
    as = field[:as]

    @field = if (id = field[:id]).present?
               Field.find(id).tap { |f| f.as = as }
             else
               field_group_id = field[:field_group_id]
               klass = find_class(Field.lookup_class(as))
               klass.new(field_group_id: field_group_id, as: as)
      end

    respond_with(@field) do |format|
      format.html { render partial: 'admin/fields/subform' }
    end
  end

  protected

  def field_params
    params[:field].permit!
  end

  def setup_current_tab
    set_current_tab('admin/fields')
  end
end
