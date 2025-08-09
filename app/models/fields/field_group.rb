# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: field_groups
#
#  id         :integer         not null, primary key
#  name       :string(64)
#  label      :string(128)
#  position   :integer
#  hint       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  tag_id     :integer
#  klass_name :string(32)
#

class FieldGroup < ActiveRecord::Base
  has_many :fields, -> { order :position }
  belongs_to :tag, optional: true
  before_destroy :not_default_field_group, :move_fields_to_default_field_group

  validates_presence_of :label

  before_save do
    self.name = label.downcase.gsub(/[^a-z0-9]+/, '_') if name.blank? && label.present?
  end

  def key
    "field_group_#{id}"
  end

  def klass
    klass_name.constantize
  end

  def self.with_tags(tag_ids)
    where 'tag_id IS NULL OR tag_id IN (?)', tag_ids
  end

  def label_i18n
    I18n.t(name, default: label)
  end

  private

  # Can't delete default field group
  def not_default_field_group
    name != "custom_fields"
  end

  # When deleted, transfer fields to default field group
  def move_fields_to_default_field_group
    default_group = FieldGroup.find_by_name_and_klass_name("custom_fields", klass_name)
    default_group.fields << fields if default_group.fields
    reload
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_field_group, self)
end
