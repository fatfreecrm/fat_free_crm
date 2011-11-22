class FieldGroup < ActiveRecord::Base
  has_many :fields

  def key
    "field_group_#{id}"
  end
end
