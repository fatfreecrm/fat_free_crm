# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::FieldGroupsController < Admin::ApplicationController

  helper 'admin/fields'

  # GET /admin/field_groups/new
  # GET /admin/field_groups/new.xml                                        AJAX
  #----------------------------------------------------------------------------
  def new
    @field_group = FieldGroup.new(:klass_name => params[:klass_name])

    respond_with(@field_group)
  end

  # GET /admin/field_groups/1/edit                                         AJAX
  #----------------------------------------------------------------------------
  def edit
    @field_group = FieldGroup.find(params[:id])

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = FieldGroup.find_by_id($1) || $1.to_i
    end

    respond_with(@field_group)
  end

  # POST /admin/field_groups
  # POST /admin/field_groups.xml                                           AJAX
  #----------------------------------------------------------------------------
  def create
    @field_group = FieldGroup.create(params[:field_group])

    respond_with(@field_group)
  end

  # PUT /admin/field_groups/1
  # PUT /admin/field_groups/1.xml                                          AJAX
  #----------------------------------------------------------------------------
  def update
    @field_group = FieldGroup.find(params[:id])
    @field_group.update_attributes(params[:field_group])

    respond_with(@field_group)
  end

  # DELETE /admin/field_groups/1
  # DELETE /admin/field_groups/1.xml                                       AJAX
  #----------------------------------------------------------------------------
  def destroy
    @field_group = FieldGroup.find(params[:id])
    @field_group.destroy

    respond_with(@field_group)
  end

  # POST /admin/field_groups/sort
  #----------------------------------------------------------------------------
  def sort
    asset = params[:asset]
    field_group_ids = params["#{asset}_field_groups"]

    field_group_ids.each_with_index do |id, index|
      FieldGroup.update_all({:position => index+1}, {:id => id})
    end

    render :nothing => true
  end

  # GET /admin/field_groups/1/confirm                                      AJAX
  #----------------------------------------------------------------------------
  def confirm
    @field_group = FieldGroup.find(params[:id])
  end
end
