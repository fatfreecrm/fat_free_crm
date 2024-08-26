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
    @field = Field.find(params["id"])
    respond_with(@field)
  end

  # POST /fields
  # POST /fields.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    as = field_params["as"]
    klass= Field.lookup_class(as).safe_constantize
    @field =
      if as.match?(/pair/)
        klass.create_pair("pair" => pair_params, "field" => field_params).first
      elsif as.present?
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
    if field_params["as"].match?(/pair/)
      @field = CustomFieldPair.update_pair("pair" => pair_params, "field" => field_params).first
    else
      @field = Field.find(params["id"])
      @field.update(field_params)
    end

    respond_with(@field)
  end

  # DELETE /fields/1
  # DELETE /fields/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @field = Field.find(params["id"])
    @field.destroy

    respond_with(@field)
  end

  # POST /fields/sort
  #----------------------------------------------------------------------------
  def sort
    field_group_id = params["field_group_id"].to_i
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
    as = field_params["as"]
    @field = if (id = field[:id]).present?
               Field.find(id).tap { |f| f.as = as }
             else
               field_group_id = field[:field_group_id]
               klass = Field.lookup_class(as).safe_constantize
               klass.new(field_group_id: field_group_id, as: as)
      end

    respond_with(@field) do |format|
      format.html { render partial: 'admin/fields/subform' }
    end
  end

  protected

  def field_params
    params.require(:field).permit(:as, :collection_string, :disabled, :field_group_id, :hint, :label, :maxlength, :minlength, :name, :pair_id, :placeholder, :position, :required, :type, settings: {})
  end

  def pair_params
    params.require(:pair).permit("0": [:hint, :required, :disabled, :id], "1": [:hint, :required, :disabled, :id])
  end

  def setup_current_tab
    set_current_tab('admin/fields')
  end
end
