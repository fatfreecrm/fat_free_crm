if defined?(Rake)
  module Rake
    Task.class_eval do
      def self.sanitize_and_execute(sql)
        sanitized = ActiveRecord::Base.send(:sanitize_sql, sql, nil)
        ActiveRecord::Base.connection.execute(sanitized)
      end
    end
  end
end
