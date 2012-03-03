class List < ActiveRecord::Base
  validates_presence_of :name

  # Parses the controller from the url
  def controller
    (url || "").sub(/^\//,'').split(/\/|\?/).first
  end
end
