require 'user_stamp'

class ActionController::Base
  extend UserStamp::ClassMethods
end
