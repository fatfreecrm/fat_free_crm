require "mysql_uuid"
ActiveRecord::Base.send(:include, ActiveRecord::Uses::MySQL::UUID)
