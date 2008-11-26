require File.dirname(__FILE__) + '/../test_helper.rb'

module ConditionTests
  class InclusiveDescendantOfTest < ActiveSupport::TestCase
    def test_sanitize
      ben = users(:ben)
      drew = users(:drew)
      jennifer = users(:jennifer)
      tren = users(:tren)
      
      condition = Searchlogic::Condition::InclusiveDescendantOf.new(User)
      condition.value = ben
      assert_equal ["(\"users\".\"id\" = ?) OR (\"users\".\"id\" = ? OR \"users\".\"id\" = ? OR \"users\".\"id\" = ?)", ben.id, drew.id, tren.id, jennifer.id], condition.sanitize
    end
  end
end