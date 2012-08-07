xml.Worksheet 'ss:Name' => I18n.t(:tab_campaigns) do
  xml.Table do
    unless @campaigns.empty?
      # Header.
      xml.Row do
        heads = [I18n.t('user'),
                 I18n.t('assigned_to'),
                 I18n.t('name'),
                 I18n.t('access'),
                 I18n.t('status'),
                 I18n.t('budget'),
                 I18n.t('option_target_leads'),
                 I18n.t('target_conversion'),
                 I18n.t('option_target_revenue'),
                 I18n.t('number_of_leads'),
                 I18n.t('total_opportunities'),
                 I18n.t('revenue'),
                 I18n.t('option_starts_on'),
                 I18n.t('option_ends_on'),
                 I18n.t('objectives'),
                 I18n.t('background_info'),
                 I18n.t('date_created'),
                 I18n.t('date_updated')]
        
        # Append custom field labels to header
        Campaign.fields.each do |field|
          heads << field.label
        end
        
        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end
      
      # Campaign rows.
      @campaigns.each do |campaign|
        xml.Row do
          data    = [campaign.user.try(:name),
                     campaign.assignee.try(:name),
                     campaign.name,
                     campaign.access,
                     campaign.status,
                     campaign.budget,
                     campaign.target_leads,
                     campaign.target_conversion,
                     campaign.target_revenue,
                     campaign.leads_count,
                     campaign.opportunities_count,
                     campaign.revenue,
                     campaign.starts_on,
                     campaign.ends_on,
                     campaign.objectives,
                     campaign.background_info,
                     campaign.created_at,
                     campaign.updated_at]
          
          # Append custom field values.
          Campaign.fields.each do |field|
            data << campaign.send(field.name)
          end
          
          data.each do |value|
            xml.Cell do
              xml.Data value,
                       'ss:Type' => "#{value.respond_to?(:abs) ? 'Number' : 'String'}"
            end
          end
        end
      end
    end
  end
end
