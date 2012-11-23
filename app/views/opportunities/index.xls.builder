xml.Worksheet 'ss:Name' => I18n.t(:tab_opportunities) do
  xml.Table do
    unless @opportunities.empty?
      # Header.
      xml.Row do
        heads = [I18n.t('user'),
                 I18n.t('campaign'),
                 I18n.t('assigned_to'),
                 I18n.t('account'),
                 I18n.t('name'),
                 I18n.t('access'),
                 I18n.t('source'),
                 I18n.t('stage'),
                 I18n.t('probability'),
                 I18n.t('amount'),
                 I18n.t('discount'),
                 I18n.t('weighted_amount'),
                 I18n.t('option_closes_on'),
                 I18n.t('date_created'),
                 I18n.t('date_updated')]
        
        # Append custom field labels to header
        Opportunity.fields.each do |field|
          heads << field.label
        end
        
        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end
      
      # Opportunity rows.
      @opportunities.each do |opportunity|
        xml.Row do
          data = [opportunity.user.try(:name),
                  opportunity.campaign.try(:name),
                  opportunity.assignee.try(:name),
                  opportunity.account.try(:name),
                  opportunity.name,
                  opportunity.access,
                  opportunity.source,
                  opportunity.stage,
                  opportunity.probability,
                  opportunity.amount,
                  opportunity.discount,
                  opportunity.weighted_amount,
                  opportunity.closes_on,
                  opportunity.created_at,
                  opportunity.updated_at]
          
          # Append custom field values.
          Opportunity.fields.each do |field|
            data << opportunity.send(field.name)
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
