# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::ImportsController < Admin::ApplicationController
  before_action :setup_current_tab, only: %i[index import]

  # GET /admin/imports
  #----------------------------------------------------------------------------
  def index
  end

  # POST /admin/imports/import
  #----------------------------------------------------------------------------
  def import
    if params[:file].nil?
      flash[:error] = t(:msg_no_file_chosen)
      redirect_to admin_imports_path and return
    end

    klass = params[:klass].classify.constantize rescue nil
    unless [Lead, Account, Campaign, Opportunity, Contact, Task].include?(klass)
      flash[:error] = t(:msg_invalid_class)
      redirect_to admin_imports_path and return
    end

    import_records(klass, params[:file])
    redirect_to admin_imports_path
  end

  private

  def import_records(klass, file)
    require 'csv'
    @imported_count = 0
    @errors = []

    CSV.foreach(file.path, headers: true) do |row|
      attributes = row.to_hash
      mapped_attributes = map_attributes(klass, attributes)

      record = klass.new(mapped_attributes)
      record.user = current_user
      record.access = Setting.default_access if record.respond_to?(:access=)

      if record.save
        @imported_count += 1
      else
        @errors << "#{row.to_s.strip}: #{record.errors.full_messages.join(', ')}"
      end
    end

    records_key = @imported_count == 1 ? klass.model_name.i18n_key : klass.model_name.i18n_key.to_s.pluralize.to_sym
    records_name = t(records_key, default: klass.model_name.human(count: @imported_count)).downcase

    if @errors.empty?
      flash[:notice] = t(:msg_imported_records, count: @imported_count, records: records_name)
    else
      flash[:warning] = t(:msg_imported_records_with_errors, count: @imported_count, records: records_name, errors: @errors.size)
      flash[:error] = @errors.join("<br/>").html_safe
    end
  end

  def map_attributes(klass, attributes)
    mapped = {}
    attributes.each do |key, value|
      next if value.blank?

      attr_name = find_attribute_name(klass, key)
      mapped[attr_name] = value if attr_name
    end
    mapped
  end

  def find_attribute_name(klass, key)
    key = key.to_s.strip
    return key if klass.column_names.include?(key)

    normalized_key = key.downcase.gsub(' ', '_')
    return normalized_key if klass.column_names.include?(normalized_key)

    klass.column_names.each do |col|
      return col if klass.human_attribute_name(col).downcase == key.downcase
    end

    nil
  end

  def setup_current_tab
    set_current_tab('admin/imports')
  end
end
