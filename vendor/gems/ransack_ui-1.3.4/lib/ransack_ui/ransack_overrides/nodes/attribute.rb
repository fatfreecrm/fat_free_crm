require 'ransack/nodes/attribute'

module Ransack
  module Nodes
    Attribute.class_eval do
      def valid?
        bound? && attr &&
        context.klassify(parent).ransackable_attributes(context.auth_object)
          .map(&:first).include?(attr_name)
      end
    end
  end
end
