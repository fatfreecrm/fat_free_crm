require "user_permissions"
ActiveRecord::Base.send(:include, ActiveRecord::Uses::User::Permissions)
