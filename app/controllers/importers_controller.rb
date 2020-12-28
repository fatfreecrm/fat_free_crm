# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

require 'json'

class ImportersController < ApplicationController
  # get /importers/new                                                 AJAX
  #----------------------------------------------------------------------------
  def new
    @importer = Importer.new
    @importer.entity_type = params[:entity_type]
    if params[:entity_id]
      @importer.entity_id = params[:entity_id]
    end
    respond_with(@importer)
  end

  # post /importers/create
  #----------------------------------------------------------------------------
  def create
    errors = false
    if params[:importer]
      @importer = Importer.create(importer_params)
      if @importer.valid?
        @importer.save
      else
        errors = @importer.errors.full_messages
      end
    end

    respond_to do |format|
      if errors
        format.html { render "create", :locals => {errors: errors} }
      else
        format.html { redirect_to form_map_columns_importer_path(@importer) }
      end
    end

  end

  # get /importers/:id/map
  #----------------------------------------------------------------------------
  def form_map_columns
    @importer = Importer.find(params[:id])
    columns = FatFreeCRM::ImportHandle.get_columns(@importer.attachment.path)

    attributes = []
    attributes_extra = []

    object = @importer.entity_class
    _attrs = object.attribute_names - ['id']

    _attrs.each do |attr|
      attributes.push(
          {
              name: attr,
              required: object.validators_on(attr).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }
          }
      )
    end

    if @importer.entity_type == 'lead'
      _attrs = Address.attribute_names - %w(id created_at updated_at deleted_at address_type addressable_type addressable_id)

      _attrs.each do |attr|
        attributes_extra.push(
            {
                name: attr,
                required: Address.validators_on(attr).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }
            }
        )
      end
    end

    respond_to do |format|
      format.html { render "form_map_columns", :locals => {columns: columns, attributes: attributes, attributes_extra: attributes_extra} }
    end
  end

  # post /importers/:id/map
  #----------------------------------------------------------------------------
  def map_columns
    @importer = Importer.find(params[:id])
    @importer.status = :map
    map = params[:map]
    @importer.map = map.to_json
    @importer.save
    @importer = FatFreeCRM::ImportHandle.process(@importer)

    respond_to do |format|
      format.html { render "map_columns" }
    end
  end

=begin
  # get /campaigns/import                                                 AJAX
  #----------------------------------------------------------------------------
  def import
    @importer = Importer.new
    @importer.entity_type = 'Campaign'
    respond_with(@importer)
  end

  # patch /campaigns/import                                                 AJAX
  #----------------------------------------------------------------------------
  def import_upload
    @error = false
    @result = {
        items: [],
        errors: []
    }

    if params[:importer]
      @importer = Importer.create(import_params)
      if @importer.valid?
        @importer.save
        @result = FatFreeCRM::ImportHandle.process(@importer)
      else
        puts @importer.errors.full_messages
        @result[:errors].push(@importer.errors.full_messages)
        @error = true
      end
    end
    respond_with(@error,@result)
  end


  # get /campaigns/%id/import                                                 AJAX
  #----------------------------------------------------------------------------
  def import_leads
    @importer = Importer.new
    @importer.entity_type = 'Lead'
    respond_with(@importer)
  end

  # patch /campaigns/import                                                 AJAX
  #----------------------------------------------------------------------------
  def uploads_import_leads
    @error = false
    @result = {
        items: [],
        errors: []
    }

    if params[:importer]
      @importer = Importer.create(import_params)
      if @importer.valid?
        @importer.save
        @colummns = FatFreeCRM::ImportHandle.get_columns(@importer.attachment.path)
      else
        puts @importer.errors.full_messages
        @result[:errors].push(@importer.errors.full_messages)
        @error = true
      end
    end
    respond_with(@colummns) do |format|
      format.js { render :uploads_import_leads }
    end
  end

=end
  # post /importers/create
  #----------------------------------------------------------------------------
=begin
  def create
    @error = false
    @result = {
        items: [],
        errors: []
    }

    if params[:importer]
      @importer = Importer.create(import_params)
      if @importer.valid?
        @importer.save
       @result = FatFreeCRM::ImportHandle.process(@importer)
      else
        puts @importer.errors.full_messages
        @result[:errors].push(@importer.errors.full_messages)
        @error = true
      end
    end
    respond_with(@error,@result)
  end
=end

  private

  def importer_params
    params.require(:importer).permit(:attachment, :entity_type, :entity_id)
  end
end
