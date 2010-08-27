require 'responds_to_parent/action_controller'
require 'responds_to_parent/selector_assertion'

module ActionController
  class Base
    include RespondsToParent::ActionController
  end
end

module ActionController
  module Assertions
    module SelectorAssertions
      include RespondsToParent::SelectorAssertion
    end
  end
end