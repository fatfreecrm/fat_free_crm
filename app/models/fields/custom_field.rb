# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: fields
#
#  id             :integer         not null, primary key
#  type           :string(255)
#  field_group_id :integer
#  position       :integer
#  name           :string(64)
#  label          :string(128)
#  hint           :string(255)
#  placeholder    :string(255)
#  as             :string(32)
#  collection     :text
#  disabled       :boolean
#  required       :boolean
#  minlength      :integer
#  maxlength      :integer
#  created_at     :datetime
#  updated_at     :datetime
#

# Implementation Notes
#------------------------------------------------------------------------------
# Adding database columns dynamically is not usually recommended,
# and can be potentially unsafe. However, the only alternative would be static migrations,
# and we want to let users add custom fields without having to restart their server.
# We could not use the EAV model for performance reasons, since we need to retain the
# ability to filter and search across thousands of records with potentially hundreds
# of custom fields.
#
# We have solved all of the major issues:
#
# * Custom fields for view templates are dynamically generated based on normalized
#   database records in the 'fields' table, instead of ActiveRecord's cached attributes.
# * Concurrency issues are resolved by using 'method_missing' to refresh a model's column information
#   when fields are added by a separate server process.
# * The custom field can be renamed or deleted, but database columns are never renamed or destroyed.
#   A rake task can be run to purge any orphaned columns.
# * Custom field types can only be changed if the database can support the transition.
#   For example, you can change an 'email' field to a 'string', but not to a 'datetime',
#   since changing the type of the database column would cause data to be lost.
#

class CustomField < Field
  delegate :table_name, to: :klass

  after_validation :update_column, on: :update
  before_create :add_column
  after_create :add_ransack_translation

  SAFE_DB_TRANSITIONS = {
    any: [%w[date time timestamp], %w[integer float]],
    one: { 'string' => 'text' }
  }

  def available_as
    Field.field_types.reject do |new_type, _params|
      db_transition_safety(as, new_type) == :unsafe
    end
  end

  # Extra validation that is called on this field when validation happens
  # obj is reference to parent object
  #------------------------------------------------------------------------------
  def custom_validator(obj)
    attr = name.to_sym
    obj.errors.add(attr, ::I18n.t('activerecord.errors.models.custom_field.required', field: label)) if required? && obj.send(attr).blank?
    obj.errors.add(attr, ::I18n.t('activerecord.errors.models.custom_field.minlength', field: label)) if (minlength.to_i > 0) && (obj.send(attr).to_s.length < minlength.to_i)
    obj.errors.add(attr, ::I18n.t('activerecord.errors.models.custom_field.maxlength', field: label)) if (maxlength.to_i > 0) && (obj.send(attr).to_s.length > maxlength.to_i)
  end

  protected

  # When changing a custom field's type, it may be necessary to
  # change the column type in the database. This method returns
  # the safety of a given transition.
  # Returns:
  #   :null   => no transition needed
  #   :safe   => transition is safe
  #   :unsafe => transition is unsafe
  #------------------------------------------------------------------------------
  def db_transition_safety(old_type, new_type = as)
    old_col, new_col = [old_type, new_type].map { |t| column_type(t).to_s }
    return :null if old_col == new_col # no transition needed
    return :safe if SAFE_DB_TRANSITIONS[:one].any? do |start, final|
      old_col == start.to_s && new_col == final.to_s # one-to-one
    end
    return :safe if SAFE_DB_TRANSITIONS[:any].any? do |col_set|
      [old_col, new_col].all? { |c| col_set.include?(c.to_s) } # any-to-any
    end
    :unsafe # Else, unsafe.
  end

  # Generate column name for custom field.
  # If column name is already taken, a numeric suffix is appended.
  # Example column sequence: cf_custom, cf_custom_2, cf_custom_3, ...
  #------------------------------------------------------------------------------
  def generate_column_name
    suffix = nil
    field_name = 'cf_' + label.downcase.gsub(/[^a-z0-9]+/, '_')
    while (final_name = [field_name, suffix].compact.join('_')) &&
          klass.column_names.include?(final_name)
      suffix = (suffix || 1) + 1
    end
    final_name
  end

  # Returns options for ActiveRecord operations
  #------------------------------------------------------------------------------
  def column_options
    Field.field_types[as][:column_options] || {}
  end

  # Create a new column to hold the custom field data
  #------------------------------------------------------------------------------
  def add_column
    self.name = generate_column_name if name.blank?
    klass.connection.add_column(table_name, name, column_type, column_options)
    klass.reset_column_information
    klass.serialize_custom_fields!
  end

  # Adds custom field translation for Ransack
  def add_ransack_translation
    I18n.backend.store_translations(Setting.locale.to_sym,
                                    ransack: { attributes: { klass.model_name.singular => { name => label } } })
    # Reset Ransack cache
    # Ransack::Helpers::FormBuilder.cached_searchable_attributes_for_base = {}
  end

  # Change database column type only if safe to do so
  # Note: columns will never be renamed or destroyed
  #------------------------------------------------------------------------------
  def update_column
    if errors.empty? && db_transition_safety(as_was) == :safe
      klass.connection.change_column(table_name, name, column_type, column_options)
      klass.reset_column_information
      klass.serialize_custom_fields!
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_custom_field, self)
end
