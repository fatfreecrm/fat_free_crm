# frozen_string_literal: true

xml.Worksheet 'ss:Name' => I18n.t(:tab_leads) do
  xml.Table do
    unless @leads.empty?
      # Header.
      xml.Row do
        heads = [I18n.t('id'),
                 I18n.t('user'),
                 I18n.t('campaign'),
                 I18n.t('job_title'),
                 I18n.t('name'),
                 I18n.t('email'),
                 I18n.t('alt_email'),
                 I18n.t('phone'),
                 I18n.t('mobile'),
                 I18n.t('company'),
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
                 I18n.t('source'),
                 I18n.t('status'),
                 I18n.t('rating'),
                 I18n.t('do_not_call'),
                 I18n.t('street1'),
                 I18n.t('street2'),
                 I18n.t('city'),
                 I18n.t('state'),
                 I18n.t('zipcode'),
                 I18n.t('country'),
                 I18n.t('address')]

        # Append custom field labels to header
        Lead.fields.each do |field|
          heads << field.label
        end

        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end

      # Lead rows.
      @leads.each do |lead|
        xml.Row do
          address = lead.business_address
          data    = [lead.id,
                     lead.user.try(:name),
                     lead.campaign.try(:name),
                     lead.title,
                     lead.name,
                     lead.email,
                     lead.alt_email,
                     lead.phone,
                     lead.mobile,
                     lead.company,
                     lead.background_info,
                     lead.blog,
                     lead.linkedin,
                     lead.facebook,
                     lead.twitter,
                     lead.skype,
                     lead.created_at,
                     lead.updated_at,
                     lead.assignee.try(:name),
                     lead.access,
                     lead.source,
                     lead.status,
                     lead.rating,
                     lead.do_not_call,
                     address.try(:street1),
                     address.try(:street2),
                     address.try(:city),
                     address.try(:state),
                     address.try(:zipcode),
                     address.try(:country),
                     address.try(:full_address)]

          # Append custom field values.
          Lead.fields.each do |field|
            data << lead.send(field.name)
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
