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
#  pair_id        :integer
#  name           :string(64)
#  label          :string(128)
#  hint           :string(255)
#  placeholder    :string(255)
#  as             :string(32)
#  collection     :text
#  disabled       :boolean
#  required       :boolean
#  maxlength      :integer
#  minlength      :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class Field < ActiveRecord::Base
  acts_as_list

  serialize :collection, Array
  serialize :settings, HashWithIndifferentAccess

  belongs_to :field_group, optional: true # TODO: Is this really optional?

  scope :core_fields,   -> { where(type: 'CoreField') }
  scope :custom_fields, -> { where("type != 'CoreField'") }
  scope :without_pairs, -> { where(pair_id: nil) }

  delegate :klass, :klass_name, :klass_name=, to: :field_group

  BASE_FIELD_TYPES = {
    'string'      => { klass: 'CustomField', type: 'string' },
    'text'        => { klass: 'CustomField', type: 'text' },
    'email'       => { klass: 'CustomField', type: 'string' },
    'url'         => { klass: 'CustomField', type: 'string' },
    'tel'         => { klass: 'CustomField', type: 'string' },
    'select'      => { klass: 'CustomField', type: 'string' },
    'radio_buttons' => { klass: 'CustomField', type: 'string' },
    'check_boxes' => { klass: 'CustomField', type: 'text' },
    'boolean'     => { klass: 'CustomField', type: 'boolean' },
    'date'        => { klass: 'CustomField', type: 'date' },
    'datetime'    => { klass: 'CustomField', type: 'timestamp' },
    'decimal'     => { klass: 'CustomField', type: 'decimal', column_options: { precision: 15, scale: 2 } },
    'integer'     => { klass: 'CustomField', type: 'integer' },
    'float'       => { klass: 'CustomField', type: 'float' }
  }.with_indifferent_access

  validates_presence_of :label, message: "^Please enter a field label."
  validates_length_of :label, maximum: 64, message: "^The field name must be less than 64 characters in length."
  validates_numericality_of :minlength, only_integer: true, greater_than_or_equal_to: 0, allow_blank: true, message: "^Min size can only be whole number."
  validates_numericality_of :minlength, less_than_or_equal_to: :maxlength, allow_blank: true, if: :maxlength, message: "^Min size cannot be greater than max size."
  validates_numericality_of :maxlength, only_integer: true, greater_than: 0, allow_blank: true, message: "^Max size can only be whole number."
  validates_presence_of :as, message: "^Please specify a field type."
  validates_inclusion_of :as, in: proc { field_types.keys }, message: "^Invalid field type.", allow_blank: true

  def column_type(field_type = as)
    (opts = Field.field_types[field_type]) ? opts[:type] : raise("Unknown field_type: #{field_type}")
  end

  def input_options
    input_html = {}
    attributes.reject do |k, v|
      !%w[as collection disabled label placeholder required minlength maxlength].include?(k) || v.blank?
    end.symbolize_keys.merge(input_html)
  end

  def collection_string=(value)
    self.collection = value.split("|").map(&:strip).reject(&:blank?)
  end

  def collection_string
    collection.try(:join, "|")
  end

  def render_value(object)
    render object.send(name)
  end

  def render(value)
    case as
    when 'checkbox'
      value.to_s == '0' ? "no" : "yes"
    when 'date'
      value&.strftime(I18n.t("date.formats.mmddyy"))
    when 'datetime'
      value&.in_time_zone&.strftime(I18n.t("time.formats.mmddyyyy_hhmm"))
    when 'check_boxes'
      value.select(&:present?).in_groups_of(2, false).map { |g| g.join(', ') }.join("<br />".html_safe) if Array === value
    else
      value.to_s
    end
  end

  class << self
    # Provides access to registered field_types
    #------------------------------------------------------------------------------
    def field_types
      @@field_types ||= BASE_FIELD_TYPES
    end

    # Register custom fields so they are available to the rest of the app
    # Example options: :as => 'datepair', :type => 'date', :klass => 'CustomFieldDatePair'
    #------------------------------------------------------------------------------
    def register(options)
      as = options.delete(:as)
      (@@field_types ||= BASE_FIELD_TYPES).merge!(as => options)
    end

    # Returns class name given a key
    #------------------------------------------------------------------------------
    def lookup_class(as)
      (@@field_types ||= BASE_FIELD_TYPES)[as][:klass]
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_field, self)
end
