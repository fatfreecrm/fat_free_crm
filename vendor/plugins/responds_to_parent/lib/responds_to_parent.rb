require 'responds_to_parent/action_controller'

ActionController::Base.send(:include, RespondsToParent)
if Rails.env.test?
  require 'responds_to_parent/selector_assertion'
  ActionDispatch::Assertions::SelectorAssertions.send(:include, RespondsToParent::SelectorAssertion)
end