module Connectable
  extend ActiveSupport::Concern

  # Attach given connected object if it hasn't been connected already.
  #----------------------------------------------------------------------------
  def attach!(connected_object)
    unless self.send("#{connected_object.class.name.downcase}_ids").include?(connected_object.id)
      self.send(connected_object.class.name.tableize) << connected_object
    end
  end

  # Discard given connected object
  #----------------------------------------------------------------------------
  def discard!(connected_object)
    if connected_object.is_a?(Task)
      connected_object.update_attribute(:asset, nil)
    else
      self.send(connected_object.class.name.tableize).delete(connected_object)
    end
  end
end
