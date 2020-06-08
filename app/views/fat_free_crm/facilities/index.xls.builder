# frozen_string_literal: true

xml.Worksheet 'ss:Name' => I18n.t(:tab_facilities) do
  xml.Table do
    unless @facilities.empty?
      # Header.
      xml.Row do
        heads = [I18n.t('id'),
                 I18n.t('user'),
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
        facility.fields.each do |field|
          heads << field.label
        end

        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end

      # facility rows.
      @facilities.each do |facility|
        xml.Row do
          address = facility.billing_address
          data    = [facility.id,
                     facility.user.try(:name),
                     facility.assignee.try(:name),
                     facility.name,
                     facility.email,
                     facility.phone,
                     facility.fax,
                     facility.website,
                     facility.background_info,
                     facility.access,
                     facility.toll_free_phone,
                     facility.rating,
                     facility.category,
                     facility.created_at,
                     facility.updated_at,
                     address.try(:street1),
                     address.try(:street2),
                     address.try(:city),
                     address.try(:state),
                     address.try(:zipcode),
                     address.try(:country),
                     address.try(:full_address)]

          # Append custom field values.
          facility.fields.each do |field|
            data << facility.send(field.name)
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
