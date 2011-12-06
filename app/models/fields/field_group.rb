class FieldGroup < ActiveRecord::Base
  has_many :fields
  belongs_to :tag

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
end

