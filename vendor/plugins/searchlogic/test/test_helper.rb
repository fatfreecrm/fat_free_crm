require "test/unit"
require "rubygems"
require "ruby-debug"
require "active_record"
require "active_record/fixtures"
require File.dirname(__FILE__) + '/libs/acts_as_tree'
require File.dirname(__FILE__) + '/libs/rexml_fix'
require File.dirname(__FILE__) + '/../lib/searchlogic' unless defined?(Searchlogic)

ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do
  create_table :accounts do |t|
    t.datetime  :created_at
    t.datetime  :updated_at
    t.string    :name
    t.boolean   :active
  end

  create_table :user_groups do |t|
    t.datetime  :created_at      
    t.datetime  :updated_at
    t.string    :name
  end
  
  create_table :user_groups_users, :id => false do |t|
    t.integer :user_group_id
    t.integer :user_id
  end
  
  create_table :users do |t|
    t.datetime  :created_at      
    t.datetime  :updated_at
    t.integer   :account_id
    t.integer   :parent_id
    t.string    :first_name
    t.string    :last_name
    t.boolean   :active
    t.text      :bio
  end

  create_table :orders do |t|
    t.datetime  :created_at      
    t.datetime  :updated_at
    t.integer   :user_id
    t.float     :total
    t.text      :description
    t.binary    :receipt
  end
  
  create_table :animals do |t|
    t.datetime  :created_at      
    t.datetime  :updated_at
    t.string   :type
    t.text     :description
  end
end


class Account < ActiveRecord::Base
  has_one :admin, :class_name => "User", :conditions => {:first_name => "Ben"}
  has_many :users, :dependent => :destroy
  has_many :orders, :through => :users
  
  named_scope :scope1, :conditions => {:users => {:first_name_contains => "Ben"}}
end

class UserGroup < ActiveRecord::Base
  has_and_belongs_to_many :users
end

class User < ActiveRecord::Base
  acts_as_tree
  belongs_to :account
  has_many :orders, :dependent => :destroy
  has_many :cats, :dependent => :destroy
  has_many :dogs, :dependent => :destroy
  has_and_belongs_to_many :user_groups
end

class Order < ActiveRecord::Base
  belongs_to :user
end

# STI
class Animal < ActiveRecord::Base
end

class Dog < Animal
end

class Cat < Animal
end

class Test::Unit::TestCase
  self.fixture_path = File.dirname(__FILE__) + "/fixtures"
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = true
  fixtures :all
  
  private
    def assert_equal_find_options(find_options, result)
      find_options_conditions = find_options.delete(:conditions)
      result_conditions = result.delete(:conditions)
      
      assert_equal find_options, result
      if find_options_conditions.blank? || result_conditions.blank?
        assert_equal find_options_conditions, result_conditions
      else
        assert_equal_sql find_options_conditions, result_conditions
      end
    end
    
    def assert_equal_sql(sql, result)
      sql_parts = breakdown_sql(sql)
      result_parts = breakdown_sql(sql)
      
      assert_equal sql_parts.size, result_parts.size
      sql_parts.each { |part| assert result_parts.include?(part) }
    end
    
    def breakdown_sql(sql)
      sanitized_sql = ActiveRecord::Base.send(:sanitize_sql, sql)
      sanitized_sql.gsub!(/(\(|\))/, "")
      sql_parts = sanitized_sql.split(/or/i)
      sql_parts.collect { |part| part.split(/ and /i) }.flatten
    end
end