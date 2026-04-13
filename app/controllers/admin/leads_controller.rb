# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::LeadsController < Admin::ApplicationController
  before_action :setup_current_tab, only: %i[index import]

  # GET /admin/leads
  #----------------------------------------------------------------------------
  def index
  end

  # POST /admin/leads/import
  #----------------------------------------------------------------------------
  def import
    if params[:file].nil?
      flash[:error] = t(:msg_no_file_chosen)
      redirect_to admin_leads_path and return
    end

    import_leads(params[:file])
    redirect_to admin_leads_path
  end

  private

  def import_leads(file)
    require 'csv'
    @imported_count = 0
    @errors = []

    CSV.foreach(file.path, headers: true) do |row|
      lead_attributes = row.to_hash
      mapped_attributes = map_attributes(lead_attributes)

      lead = Lead.new(mapped_attributes)
      lead.user = current_user
      lead.access = Setting.default_access

      if lead.save
        @imported_count += 1
      else
        @errors << "#{row.to_s.strip}: #{lead.errors.full_messages.join(', ')}"
      end
    end

    if @errors.empty?
      flash[:notice] = t(:msg_imported_leads, count: @imported_count)
    else
      flash[:warning] = t(:msg_imported_leads_with_errors, count: @imported_count, errors: @errors.size)
      flash[:error] = @errors.join("<br/>").html_safe
    end
  end

  def map_attributes(attributes)
    mapped = {}
    attributes.each do |key, value|
      next if value.blank?

      attr_name = find_attribute_name(key)
      mapped[attr_name] = value if attr_name
    end
    mapped
  end

  def find_attribute_name(key)
    key = key.to_s.strip
    return key if Lead.column_names.include?(key)

    normalized_key = key.downcase.gsub(' ', '_')
    return normalized_key if Lead.column_names.include?(normalized_key)

    Lead.column_names.each do |col|
      return col if Lead.human_attribute_name(col).downcase == key.downcase
    end

    nil
  end

  def setup_current_tab
    set_current_tab('admin/leads')
  end
end
