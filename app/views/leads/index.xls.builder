xml.Worksheet 'ss:Name' => I18n.t(:tab_leads) do
  xml.Table do
    unless @leads.empty?
      # Header.
      xml.Row do
        columns = %w{user campaign job_title name email alt_email phone mobile company background_info blog linked_in facebook twitter skype date_created date_updated assigned_to access source status rating do_not_call
                     street1 street2 city state zipcode country address}
        
        for column in columns
          xml.Cell do
            xml.Data I18n.t(column), 'ss:Type' => 'String'
          end
        end
      end
      
      # Contact rows.
      for l in @leads
        xml.Row do
          a = l.business_address
          values = [l.user.try(:name), l.campaign.try(:name), l.title, l.name, l.email, l.alt_email, l.phone, l.mobile, l.company, l.background_info, l.blog, l.linkedin, l.facebook, l.twitter, l.skype, l.created_at, l.updated_at, l.assignee.try(:name), l.access, l.source, l.status, l.rating, l.do_not_call]
          
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
