class Array
  #hacky, used in the home controller, get_activities action
  #since visible_to returns an array, could limit it at the first scope in the chain, but some may be removed further down
  # Activity.latest(options).except(:viewed).visible_to(@current_user).limit(options[:limit])
  def limit(n)
    if n.is_a?(Integer)
      limited_array = []
      n.times do |i|
        self[i].present? ? limited_array << self[i] : break
      end
    else
      return self
    end
    limited_array
  end
end