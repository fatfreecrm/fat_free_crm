require 'ransack/nodes/condition'

module Ransack
  module Nodes
    Condition.class_eval do
      attr_writer :is_default

      def default?
        @is_default
      end
    end
  end
end