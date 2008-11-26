module Searchlogic
  module Condition
    class Equals < Base
      self.handle_array_value = true
      self.ignore_meaningless_value = false
      
      class << self
        def condition_names_for_column
          super + ["", "is"]
        end
      end
      
      def to_conditions(value)
        # Let ActiveRecord handle this
        args = []
        case value
        when Range
          args = [value.first, value.last]
        else
          args << value
        end
                        
        ["#{column_sql} #{klass.send(:attribute_condition, value)}", *args]
      end
    end
  end
end