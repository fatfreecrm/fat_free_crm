xml.Styles do
  xml.Style('ss:ID' => 's21') do
    xml.Font'x:Family' => 'Swiss', 'ss:Bold' => "1"
  end
  xml.Style('ss:ID' => 's22') do
    xml.Font'x:Family' => 'Swiss', 'ss:Bold' => "1", "ss:Size" => "16"
  end
end
xml.Worksheet 'ss:Name' => @event_instance.event.name do
  xml.Table do
    unless @event_instance.attendances.empty?
      #xml.Column 'ss:Width'=>"15"
      #xml.Column 'ss:Width'=>"5"
      # Title
      xml.Row do
        xml.Cell('ss:StyleID'=>'s22') do
          xml.Data "#{@event_instance.event.name}: #{@event_instance.name} - #{@event_instance.starts_at.strftime("%I:%M %p %a %d %b")}", 'ss:Type' => 'String'
        end
      end
      
      # Header.
      xml.Row do
        columns = %w{first_name last_name last_attended comments}
        
        for column in columns
          xml.Cell('ss:StyleID'=>"s21") do
            xml.Data column, 'ss:Type' => 'String'
          end
        end
      end
      
      # Attendance (Contact) rows.
      for a in @event_instance.attendances
        xml.Row do
          comments = a.comments.map{|c| "#{c.user.first_name}: #{c.comment}"}.to_sentence(:words_connector => " | ", :two_words_connector => " | ", :last_word_connector => " | ")
          values = [a.contact.try(:first_name), 
                    a.contact.try(:last_name), 
                    time_ago_in_words(a.contact.last_attendance_at_event_category(@event_instance.event.category))]
          unless comments.nil?
            values.concat [comments]
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
