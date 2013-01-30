xml.Worksheet 'ss:Name' => I18n.t(:tab_groups) do
  xml.Table do
    unless @contact_groups.empty?
      # Header.
      xml.Row do
        columns = %w{contact_group name email phone mobile background_info 
                     street1 street2 city state zipcode country address}
        
        for column in columns
          xml.Cell do
            xml.Data I18n.t(column), 'ss:Type' => 'String'
          end
        end
      end
      
      # Contact rows.
      for cg in @contact_groups
        for c in cg.contacts
          xml.Row do
              a = c.addresses.first
              values = [cg.name, c.full_name, c.email, c.phone, c.mobile, c.background_info]
          
            unless a.nil?
              values.concat [a.street1, a.street2, a.city, a.state, a.zipcode, a.country, a.full_address]
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
end
