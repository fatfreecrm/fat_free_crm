class List < ActiveRecord::Base
  # Parses the controller from the url
  def controller
    (url || "").sub(/^\//,'').split(/\/|\?/).first
  end
end
