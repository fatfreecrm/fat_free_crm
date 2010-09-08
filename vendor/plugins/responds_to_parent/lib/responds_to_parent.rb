require 'responds_to_parent/action_controller'

module ActionController
  class Base
    include RespondsToParent::ActionController
  end
end

if ENV["RAILS_ENV"] == "test"
  require 'responds_to_parent/selector_assertion'
  module ActionController
    module Assertions
      module SelectorAssertions
        include RespondsToParent::SelectorAssertion
      end
    end
  end
end