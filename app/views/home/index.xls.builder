# frozen_string_literal: true

xml.Worksheet 'ss:Name' => I18n.t(:tab_dashboard) do
  xml.Table do
    unless @activities.empty?

      xml.Row do
        heads = ["Id",
                 "Item type",
                 "Item",
                 "Event",
                 "Whodunnit",
                 "Object",
                 "Created at",
                 "Object changes",
                 "Related",
                 "Related type",
                 "Transaction"]

        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end

      @activities.each do |activity|
        xml.Row do
          data = [activity.id,
                  activity.item_type,
                  activity.item_id,
                  activity.event,
                  activity.whodunnit,
                  activity.object,
                  activity.created_at,
                  activity.object_changes,
                  activity.related_id,
                  activity.related_type,
                  activity.transaction_id]

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
