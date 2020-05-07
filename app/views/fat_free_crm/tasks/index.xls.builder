# frozen_string_literal: true

xml.Worksheet 'ss:Name' => I18n.t(:tab_tasks) do
  xml.Table do
    unless @tasks.empty?
      # Header.
      xml.Row do
        heads = %w[id
                   name
                   due
                   date_created
                   date_updated
                   completed
                   user
                   assigned_to
                   category
                   background_info]

        heads.each do |head|
          xml.Cell do
            xml.Data I18n.t(head),
                     'ss:Type' => 'String'
          end
        end
      end

      # Rows.
      @tasks.map(&:second).flatten.each do |task|
        xml.Row do
          data = [task.id,
                  task.name,
                  I18n.t(task.computed_bucket),
                  task.created_at,
                  task.updated_at,
                  task.completed_at,
                  task.user.try(:name),
                  task.assignee.try(:name),
                  task.category,
                  task.background_info]

          data.each do |value|
            xml.Cell do
              xml.Data value,
                       'ss:Type' => (value.respond_to?(:abs) ? 'Number' : 'String').to_s
            end
          end
        end
      end
    end
  end
end
