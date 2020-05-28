require 'ransack/nodes/grouping'

module Ransack
  module Nodes
    Grouping.class_eval do

      def new_condition(opts = {})
        attrs = opts[:attributes] || 1
        vals = opts[:values] || 1
        condition = Condition.new(@context)
        condition.predicate_name = opts[:predicate] || 'eq'
        condition.is_default = true
        attrs.times { condition.build_attribute }
        vals.times { condition.build_value }
        condition
      end

    end
  end
end