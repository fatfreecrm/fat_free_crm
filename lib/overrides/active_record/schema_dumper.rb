#
# Override SchemaDumper so that it ignores custom fields when generating db/schema.rb
#
require 'active_record'

module ActiveRecord
  SchemaDumper.class_eval do
    def initialize_with_ignored_custom_fields(connection)
      # Override :columns method on this connection, to ignore any custom field columns
      connection.class_eval do
        def columns(*args)
          super.reject { |c| c.name.start_with? "cf_" }
        end
      end
      initialize_without_ignored_custom_fields(connection)
    end

    alias_method_chain :initialize, :ignored_custom_fields
  end
end