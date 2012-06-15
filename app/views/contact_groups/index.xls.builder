xml.Worksheet 'ss:Name' => I18n.t(:tab_accounts) do
  xml.Table do
    unless @accounts.empty?
      # Header.
      xml.Row do
        columns = %w{user assigned_to name email phone fax website background_info access phone_toll_free rating category date_created date_updated
                     street1 street2 city state zipcode country address}
        
        for column in columns
          xml.Cell do
            xml.Data I18n.t(column), 'ss:Type' => 'String'
          end
        end
      end
      
      # Contact rows.
      for a in @accounts
        xml.Row do
          ba = a.billing_address
          values = [a.user.try(:name), a.assignee.try(:name), a.name, a.email, a.phone, a.fax, a.website, a.background_info, a.access, a.toll_free_phone, a.rating, a.category, a.created_at, a.updated_at]
          
          unless ba.nil?
            values.concat [ba.street1, ba.street2, ba.city, ba.state, ba.zipcode, ba.country, ba.full_address]
          end
          
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
