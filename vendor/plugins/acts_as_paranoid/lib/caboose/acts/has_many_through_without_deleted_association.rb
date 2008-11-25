module Caboose # :nodoc:
  module Acts # :nodoc:
    class HasManyThroughWithoutDeletedAssociation < ActiveRecord::Associations::HasManyThroughAssociation
      protected
        def current_time
          ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now
        end

        def construct_conditions
          return super unless @reflection.through_reflection.klass.paranoid?
          table_name = @reflection.through_reflection.table_name
          conditions = construct_quoted_owner_attributes(@reflection.through_reflection).map do |attr, value|
            "#{table_name}.#{attr} = #{value}"
          end

          deleted_attribute = @reflection.through_reflection.klass.deleted_attribute
          quoted_current_time = @reflection.through_reflection.klass.quote_value(
            current_time,
            @reflection.through_reflection.klass.columns_hash[deleted_attribute.to_s])
          conditions << "#{table_name}.#{deleted_attribute} IS NULL OR #{table_name}.#{deleted_attribute} > #{quoted_current_time}"

          conditions << sql_conditions if sql_conditions
          "(" + conditions.join(') AND (') + ")"
        end
    end
  end
end