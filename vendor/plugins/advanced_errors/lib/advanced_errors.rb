require 'advanced_errors/full_messages'
ActiveRecord::Errors.send :include, Nexx::AdvancedErrors::FullMessages