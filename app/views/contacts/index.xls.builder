xml.Worksheet 'ss:Name' => I18n.t(:tab_contacts) do
  xml.Table do
    unless @contacts.empty?
      # Header.
      xml.Row do
        columns = %w{lead job_title name email alt_email phone mobile fax born_on background_info blog linked_in facebook twitter skype date_created date_updated assigned_to access department source do_not_call
                     street1 street2 city state zipcode country address}
        
        for column in columns
          xml.Cell do
            xml.Data I18n.t(column), 'ss:Type' => 'String'
          end
        end
      end
      
      # Contact rows.
      for c in @contacts
        xml.Row do
          a = c.business_address
          values = [c.lead.try(:name), c.title, c.name, c.email, c.alt_email, c.phone, c.mobile, c.fax, c.born_on, c.background_info, c.blog, c.linkedin, c.facebook, c.twitter, c.skype, c.created_at, c.updated_at, c.assignee.try(:name), c.access, c.department, c.source, c.do_not_call]
          
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
