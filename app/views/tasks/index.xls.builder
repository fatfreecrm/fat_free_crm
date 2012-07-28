xml.Worksheet 'ss:Name' => I18n.t(:tab_tasks) do
  xml.Table do
    unless @tasks.empty?
      # Header.
      xml.Row do
        columns = %w{name due date_created date_updated completed user assigned_to category background_info}
        
        for column in columns
          xml.Cell do
            xml.Data I18n.t(column), 'ss:Type' => 'String'
          end
        end
      end
      
      # Rows.
      for t in @tasks.map(&:second).flatten
        xml.Row do
          values = [t.name, I18n.t(t.computed_bucket), t.created_at, t.updated_at, t.completed_at, t.user.try(:name), t.assignee.try(:name), t.category, t.background_info]
                    
          for value in values
            xml.Cell do
              xml.Data value, 'ss:Type' => "#{value.respond_to?(:abs) ? 'Number' : 'String'}"
            end
          end
        end
      end
    end
  end
end
