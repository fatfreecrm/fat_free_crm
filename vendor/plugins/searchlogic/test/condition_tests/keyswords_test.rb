require File.dirname(__FILE__) + '/../test_helper.rb'

module ConditionTests
  class KeywordsTest < ActiveSupport::TestCase
    def test_sanitize
      condition = Searchlogic::Condition::Keywords.new(Account, :column => Account.columns_hash["name"])
      condition.value = "freedom yeah, freedom YEAH right"
      assert_equal ["\"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ?", "%freedom%", "%yeah%", "%right%"], condition.sanitize
    
      condition = Searchlogic::Condition::Keywords.new(Account, :column => Account.columns_hash["name"])
      condition.value = "%^$*(^$)"
      assert_nil condition.sanitize
    
      condition = Searchlogic::Condition::Keywords.new(Account, :column => Account.columns_hash["name"])
      condition.value = "%^$*(^$) àáâãäåßéèêëìíîïñòóôõöùúûüýÿ"
      assert_equal ["\"accounts\".\"name\" LIKE ?", "%àáâãäåßéèêëìíîïñòóôõöùúûüýÿ%"], condition.sanitize
    end
  end
end