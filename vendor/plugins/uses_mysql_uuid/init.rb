require "mysql_uuid"
require "mysql_uuid_schema"
ActiveRecord::Base.send(:include, ActiveRecord::Uses::MySQL::UUID)
