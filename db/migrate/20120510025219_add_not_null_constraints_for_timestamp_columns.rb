class AddNotNullConstraintsForTimestampColumns < ActiveRecord::Migration
  def up
    set_timestamp_constraints :null => false unless $FFCRM_NEW_DATABASE
  end

  def down
    set_timestamp_constraints {} unless $FFCRM_NEW_DATABASE
  end

  private
  def set_timestamp_constraints(constraints)
    ActiveRecord::Base.connection.tables.each do |table|
      # If table has both timestamp columns, set not null constraints on both columns.
      if [:created_at, :updated_at].all? { |column| column_exists?(table, column) }
        [:created_at, :updated_at].each do |column|
          change_column table, column, :datetime, constraints
        end
      end
    end
  end
end
