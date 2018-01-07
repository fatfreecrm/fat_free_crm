# frozen_string_literal: true

xml.Worksheet 'ss:Name' => I18n.t(:tab_contacts) do
  xml.Table do
    unless @contacts.empty?
      # Header.
      xml.Row do
        heads = [I18n.t('id'),
                 I18n.t('lead'),
                 I18n.t('job_title'),
                 I18n.t('name'),
                 I18n.t('first_name'),
                 I18n.t('last_name'),
                 I18n.t('email'),
                 I18n.t('alt_email'),
                 I18n.t('phone'),
                 I18n.t('mobile'),
                 I18n.t('fax'),
                 I18n.t('born_on'),
                 I18n.t('background_info'),
                 I18n.t('blog'),
                 I18n.t('linked_in'),
                 I18n.t('facebook'),
                 I18n.t('twitter'),
                 I18n.t('skype'),
                 I18n.t('date_created'),
                 I18n.t('date_updated'),
                 I18n.t('assigned_to'),
                 I18n.t('access'),
                 I18n.t('department'),
                 I18n.t('source'),
                 I18n.t('do_not_call'),
                 I18n.t('street1'),
                 I18n.t('street2'),
                 I18n.t('city'),
                 I18n.t('state'),
                 I18n.t('zipcode'),
                 I18n.t('country'),
                 I18n.t('address')]

        # Append custom field labels to header
        Contact.fields.each do |field|
          heads << field.label
        end

        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end

      # Contact rows.
      @contacts.each do |contact|
        xml.Row do
          address = contact.business_address
          data    = [contact.id,
                     contact.lead.try(:name),
                     contact.title,
                     contact.name,
                     contact.first_name,
                     contact.last_name,
                     contact.email,
                     contact.alt_email,
                     contact.phone,
                     contact.mobile,
                     contact.fax,
                     contact.born_on,
                     contact.background_info,
                     contact.blog,
                     contact.linkedin,
                     contact.facebook,
                     contact.twitter,
                     contact.skype,
                     contact.created_at,
                     contact.updated_at,
                     contact.assignee.try(:name),
                     contact.access,
                     contact.department,
                     contact.source,
                     contact.do_not_call,
                     address.try(:street1),
                     address.try(:street2),
                     address.try(:city),
                     address.try(:state),
                     address.try(:zipcode),
                     address.try(:country),
                     address.try(:full_address)]

          # Append custom field values.
          Contact.fields.each do |field|
            data << contact.send(field.name)
          end

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
