require File.dirname(__FILE__) + '/../test_helper.rb'

module ConditionsTests
  class BaseTest < ActiveSupport::TestCase
    def test_register_conditions
      Searchlogic::Conditions::Base.register_condition(Searchlogic::Condition::Keywords)
      assert [Searchlogic::Condition::Keywords], Searchlogic::Conditions::Base.conditions
    
      Searchlogic::Conditions::Base.register_condition(Searchlogic::Condition::Like)
      assert [Searchlogic::Condition::Keywords, Searchlogic::Condition::Like], Searchlogic::Conditions::Base.conditions
    end
  
    def test_association_names
      ["dogs", "children", "user_groups", "orders", "account", "parent", "cats"].each do |name|
        assert Searchlogic::Cache::UserConditions.association_names.include? name
      end
      ["admin", "orders", "users"].each do |name|
        Searchlogic::Cache::AccountConditions.association_names.include? name
      end
    end
  
    def test_needed
      assert (not Searchlogic::Conditions::Base.needed?(User, {}))
      assert (not Searchlogic::Conditions::Base.needed?(User, {:first_name => "Ben"}))
      assert Searchlogic::Conditions::Base.needed?(User, {:first_name_contains => "Awesome"})
      assert (not Searchlogic::Conditions::Base.needed?(User, {"orders.id" => 2}))
    end
  
    def test_initialize
      conditions = Searchlogic::Cache::AccountConditions.new(:name_contains => "Binary")
      assert_equal conditions.klass, Account
      assert_equal conditions.name_contains, "Binary"
    end
  
    def test_any
      conditions = Searchlogic::Cache::AccountConditions.new
      assert (not conditions.any?)
      conditions = Searchlogic::Cache::AccountConditions.new(:any => true)
      assert conditions.any?
      conditions.any = "false"
      assert (not conditions.any?)
      conditions = Searchlogic::Cache::AccountConditions.new
      conditions.name_contains = "Binary"
      assert_equal_sql ["\"accounts\".\"name\" LIKE ?", "%Binary%"], conditions.sanitize
      conditions.id = 1
      assert_equal_sql ["(\"accounts\".\"id\" = ?) AND (\"accounts\".\"name\" LIKE ?)", 1, "%Binary%"], conditions.sanitize
      conditions.any = true
      assert_equal_sql ["(\"accounts\".\"id\" = ?) OR (\"accounts\".\"name\" LIKE ?)", 1, "%Binary%"], conditions.sanitize
      conditions.any = false
      assert_equal_sql ["(\"accounts\".\"id\" = ?) AND (\"accounts\".\"name\" LIKE ?)", 1, "%Binary%"], conditions.sanitize
    end
  
    def test_auto_joins
      conditions = Searchlogic::Cache::AccountConditions.new
      assert_equal conditions.auto_joins, nil
    
      conditions.name_like = "Binary"
      assert_equal conditions.auto_joins, nil
    
      conditions.users.first_name_like = "Ben"
      assert_equal conditions.auto_joins, :users
    
      conditions.users.orders.description_like = "apple"
      assert_equal conditions.auto_joins, {:users => :orders} 
    end
  
    def test_inspect
      conditions = Searchlogic::Cache::AccountConditions.new
      assert_nothing_raised { conditions.inspect }
    end
  
    def test_sanitize
      conditions = Searchlogic::Cache::AccountConditions.new
      conditions.name_contains = "Binary"
      conditions.id_gt = 5
      now = Time.now
      conditions.created_after = now
      assert_equal_sql ["(\"accounts\".\"created_at\" > ?) AND (\"accounts\".\"id\" > ?) AND (\"accounts\".\"name\" LIKE ?)", now, 5, "%Binary%"], conditions.sanitize
    
      # test out associations
      conditions.users.first_name_like = "Ben"
      conditions.users.id_gt = 10
      conditions.users.orders.total_lt = 500
      assert_equal_sql ["(\"accounts\".\"created_at\" > ?) AND (\"accounts\".\"id\" > ?) AND (\"accounts\".\"name\" LIKE ?) AND ((\"users\".\"first_name\" LIKE ?) AND (\"users\".\"id\" > ?) AND (\"orders\".\"total\" < ?))", now, 5, "%Binary%", "%Ben%", 10, 500], conditions.sanitize
    
      # test that raw sql is returned
      conditions.conditions = "awesome"
      assert_equal "awesome", conditions.sanitize
    end
  
    def test_conditions
      conditions = Searchlogic::Cache::AccountConditions.new
      now = Time.now
      v = {:name_like => "Binary", :created_at_greater_than => now}
      conditions.conditions = v
      assert_equal v, conditions.conditions
    
      sql = "id in (1,2,3,4)"
      conditions.conditions = sql
      assert_equal sql, conditions.conditions
      assert_equal({}, conditions.send(:objects))
    
      v2 = {:id_less_than => 5, :name_begins_with => "Beginning of string"}
      conditions.conditions = v2
      assert_equal v2, conditions.conditions
    
      v = {:name_like => "Binary", :created_at_greater_than => now}
      conditions.conditions = v
      assert_equal v2.merge(v), conditions.conditions
    
      sql2 = "id > 5 and name = 'Test'"
      conditions.conditions = sql2
      assert_equal sql2, conditions.conditions
      assert_equal({}, conditions.send(:objects))
    
      conditions.name_contains = "awesome"
      assert_equal({:name_like => "awesome"}, conditions.conditions)
    
      now = Time.now
      conditions.conditions = {:id_gt => "", :id => "", :name => ["", "", ""], :created_at => ["", now], :name_starts_with => "Ben"}
      assert_equal({:name_like => "awesome", :name_begins_with => "Ben", :created_at_equals => now}, conditions.conditions)
    end
  
    # Other general usage tests, need to clean these up
  
    def test_setting_conditions
      [Account, User, Order].each do |klass|
        conditions = "Searchlogic::Cache::#{klass}Conditions".constantize.new
        conditions.class.condition_names.each do |condition_name|
          conditions.send("#{condition_name}=", 1)
          assert_equal 1, conditions.send(condition_name)
        end
      end
    end
  
    def test_accessible_protected_conditions
      Account.conditions_accessible << :name_contains
      conditions = Searchlogic::Cache::AccountConditions.new
      conditions.conditions = {:created_after => Time.now, :name_contains => "Binary"}
      assert({:name_contains => "Binary"}, conditions.conditions)
      Account.send(:write_inheritable_attribute, :conditions_accessible, nil)
    
      Account.conditions_protected << :name_contains
      conditions = Searchlogic::Cache::AccountConditions.new
      now = Time.now
      conditions.conditions = {:created_after => now, :name_contains => "Binary"}
      assert({:created_after => now}, conditions.conditions)
      Account.send(:write_inheritable_attribute, :conditions_protected, nil)
    end
  
    def test_assert_valid_values
      conditions = Searchlogic::Cache::UserConditions.new
      assert_raise(NoMethodError) { conditions.conditions = {:unknown => "blah"} }
      assert_nothing_raised { conditions.conditions = {:first_name => "blah"} }
      assert_nothing_raised { conditions.conditions = {:first_name_contains => "blah"} }
    end
  
    def test_setting_associations
      conditions = Searchlogic::Cache::AccountConditions.new(:users => {:first_name_like => "Ben"})
      assert_equal conditions.users.first_name_like, "Ben"
    
      conditions.users.last_name_begins_with = "Ben"
      assert_equal conditions.users.last_name_begins_with, "Ben"
    end
  
    def test_virtual_columns
      conditions = Searchlogic::Cache::AccountConditions.new
      conditions.hour_of_created_gt = 2
      assert_equal_sql ["strftime('%H', \"accounts\".\"created_at\") > ?", 2], conditions.sanitize
      conditions.dow_of_created_at_most = 5
      assert_equal_sql ["(strftime('%w', \"accounts\".\"created_at\") <= ?) AND (strftime('%H', \"accounts\".\"created_at\") > ?)", 5, 2], conditions.sanitize
      conditions.month_of_created_at_nil = true
      assert_equal_sql ["(strftime('%w', \"accounts\".\"created_at\") <= ?) AND (strftime('%H', \"accounts\".\"created_at\") > ?) AND (strftime('%m', \"accounts\".\"created_at\") IS NULL)", 5, 2], conditions.sanitize
      conditions.min_of_hour_of_month_of_created_at_nil = true
      assert_equal_sql ["(strftime('%w', \"accounts\".\"created_at\") <= ?) AND (strftime('%H', \"accounts\".\"created_at\") > ?) AND (strftime('%m', strftime('%H', strftime('%M', \"accounts\".\"created_at\"))) IS NULL) AND (strftime('%m', \"accounts\".\"created_at\") IS NULL)", 5, 2], conditions.sanitize
    end
  
    def test_objects
      conditions = Searchlogic::Cache::AccountConditions.new
      assert_equal({}, conditions.send(:objects))
    
      conditions.name_contains = "Binary"
      assert_equal 1, conditions.send(:objects).size
    
      conditions.users.first_name_contains = "Ben"
      assert_equal 2, conditions.send(:objects).size
    end
  
    def test_reset
      conditions = Searchlogic::Cache::AccountConditions.new
    
      conditions.name_contains = "Binary"
      assert_equal 1, conditions.send(:objects).size
    
      conditions.reset_name_like!
      conditions.reset_name_contains! # should set up aliases for reset
      assert_equal({}, conditions.send(:objects))
    
      conditions.users.first_name_like = "Ben"
      assert_equal 1, conditions.send(:objects).size
    
      conditions.reset_users!
      assert_equal({}, conditions.send(:objects))
    
      conditions.name_begins_with ="Binary"
      conditions.users.orders.total_gt = 200
      assert_equal 2, conditions.send(:objects).size
    
      conditions.reset_name_begins_with!
      assert_equal 1, conditions.send(:objects).size
    
      conditions.reset_users!
      assert_equal({}, conditions.send(:objects))
    end
  
    def test_method_conflicts
      conditions = Searchlogic::Cache::AccountConditions.new
      assert_nil conditions.id
    end
  end
end