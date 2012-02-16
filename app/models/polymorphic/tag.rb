class Tag < ActsAsTaggableOn::Tag

  before_destroy :check_if_associated_field_groups

  private
  # Don't allow a tag to be deleted if it is associated with a Field Group
  def check_if_associated_field_groups
    FieldGroup.find_all_by_tag_id(self).none?
  end
end
