class ActiveRecord::NamedScope::Scope

  # The following is used to filter out user activities based on activity
  # subject's permissions. For example:
  # 
  # @current_user = User.find(1)
  # @activities = Activity.latest.execpt(:viewed).visible_to(@current_user)
  #
  # Note that we can't use named scope for the Activity since the join table
  # name is based on subject type, which is polymorphic.
  #----------------------------------------------------------------------------
  def visible_to(user)
    delete_if do |item|
      if item.is_a?(Activity) && item.subject.respond_to?(:access) # NOTE: Tasks don't have :access as of yet.
        (item.subject.access == "Private" && item.subject.user_id != user.id && item.subject.assigned_to != user.id) ||
        (item.subject.access == "Shared"  && !item.subject.permissions.map(&:user_id).include?(user.id))
      else
        false
      end
    end
  end

end
