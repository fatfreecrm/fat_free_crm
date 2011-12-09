class FieldGroup < ActiveRecord::Base
  has_many :fields, :order => :position
  belongs_to :tag, :class_name => 'ActsAsTaggableOn::Tag'

  validates_presence_of :label

  before_save do
    self.name = label.downcase.gsub(/[^a-z0-9]+/, '_') if name.blank? and label.present?
  end

  def key
    "field_group_#{id}"
  end

  def klass
    klass_name.constantize
  end

  def core_fields
    fields.where(:type => 'CoreField')
  end

  def custom_fields
    fields.where(:type => 'CustomField')
  end

  def self.with_tags(tag_ids)
    where 'tag_id IS NULL OR tag_id IN (?)', tag_ids
  end

  def label_i18n
    I18n.t(name, :default => label)
  end
end

