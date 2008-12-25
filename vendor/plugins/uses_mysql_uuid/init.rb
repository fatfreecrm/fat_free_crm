require "mysql_uuid"
ActiveRecord::Base.send :include, MySQL_UUID
