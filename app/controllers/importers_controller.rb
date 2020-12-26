# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

class ImportersController < ApplicationController

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
    params.require(:importer).permit(:attachment,:entity_type,:entity_id)
  end
end
