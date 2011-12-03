class FieldGroup < ActiveRecord::Base
  has_many :fields
  belongs_to :tag

  def key
    "field_group_#{id}"
  end
end

