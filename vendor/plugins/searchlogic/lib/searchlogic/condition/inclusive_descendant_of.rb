module Searchlogic
  module Condition
    class InclusiveDescendantOf < Tree      
      def to_conditions(value)
        condition = DescendantOf.new(klass, options)
        condition.value = value
        merge_conditions(["#{quoted_table_name}.#{quote_column_name(klass.primary_key)} = ?", (value.is_a?(klass) ? value.send(klass.primary_key) : value)], condition.sanitize, :any => true)
      end
    end
  end
end