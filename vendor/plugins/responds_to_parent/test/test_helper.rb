ENV["RAILS_ENV"] = "test"
require File.dirname(__FILE__) + '/../config/environment'
#require 'test/unit'
require File.dirname(__FILE__) + '/../lib/responds_to_parent'
require 'test_help'

class ActiveSupport::TestCase
end
