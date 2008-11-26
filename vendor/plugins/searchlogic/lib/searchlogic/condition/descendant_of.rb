module Searchlogic
  module Condition
    class DescendantOf < Tree      
      def to_conditions(value)
        # Wish I knew how to do this in SQL
        root = (value.is_a?(klass) ? value : klass.find(value)) rescue return
        strs = []
        subs = []
        all_children_ids(root).each do |child_id|
          strs << "#{quoted_table_name}.#{quote_column_name(klass.primary_key)} = ?"
          subs << child_id
        end
        [strs.join(" OR "), *subs]
      end
      
      private
        def all_children_ids(record)
          ids = record.children.collect { |child| child.send(klass.primary_key) }
          record.children.each { |child| ids += all_children_ids(child) }
          ids
        end
    end
  end
end