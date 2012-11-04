xml.Worksheet 'ss:Name' => I18n.t(:tab_accounts) do
  xml.Table do
    unless @accounts.empty?
      # Header.
      xml.Row do
        heads = [I18n.t('user'),
                 I18n.t('assigned_to'),
                 I18n.t('name'),
                 I18n.t('email'),
                 I18n.t('phone'),
                 I18n.t('fax'),
                 I18n.t('website'),
                 I18n.t('background_info'),
                 I18n.t('access'),
                 I18n.t('phone_toll_free'),
                 I18n.t('rating'),
                 I18n.t('category'),
                 I18n.t('date_created'),
                 I18n.t('date_updated'),
                 I18n.t('street1'),
                 I18n.t('street2'),
                 I18n.t('city'),
                 I18n.t('state'),
                 I18n.t('zipcode'),
                 I18n.t('country'),
                 I18n.t('address')]
        
        # Append custom field labels to header
        Account.fields.each do |field|
          heads << field.label
        end
        
        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end
      
      # Account rows.
      @accounts.each do |account|
        xml.Row do
          address = account.billing_address
          data    = [account.user.try(:name),
                     account.assignee.try(:name),
                     account.name,
                     account.email,
                     account.phone,
                     account.fax,
                     account.website,
                     account.background_info,
                     account.access,
                     account.toll_free_phone,
                     account.rating,
                     account.category,
                     account.created_at,
                     account.updated_at,
                     address.try(:street1),
                     address.try(:street2),
                     address.try(:city),
                     address.try(:state),
                     address.try(:zipcode),
                     address.try(:country),
                     address.try(:full_address)]
                     
          # Append custom field values.
          Account.fields.each do |field|
            data << account.send(field.name)
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
