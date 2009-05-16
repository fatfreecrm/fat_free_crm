ActiveRecord::ConnectionAdapters::SchemaStatements.module_eval do

  def add_uuid_trigger(table, column = :uuid, options = { :index => true })
    if adapter_name.downcase == "mysql"
      if select_value("select version()").to_i >= 5
        execute("CREATE TRIGGER #{table}_#{column} BEFORE INSERT ON #{table} FOR EACH ROW SET NEW.#{column} = UUID()")
        add_index(table, column) if options[:index]
      end
    end
  end

end