# frozen_string_literal: true

xml.Worksheet 'ss:Name' => I18n.t(:tab_index_cases) do
  xml.Table do
    unless @index_cases.empty?
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
        index_case.fields.each do |field|
          heads << field.label
        end

        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end

      # index_case rows.
      @index_cases.each do |index_case|
        xml.Row do
          address = index_case.billing_address
          data    = [index_case.id,
                     index_case.user.try(:name),
                     index_case.assignee.try(:name),
                     index_case.name,
                     index_case.email,
                     index_case.phone,
                     index_case.fax,
                     index_case.website,
                     index_case.background_info,
                     index_case.access,
                     index_case.toll_free_phone,
                     index_case.rating,
                     index_case.category,
                     index_case.created_at,
                     index_case.updated_at,
                     address.try(:street1),
                     address.try(:street2),
                     address.try(:city),
                     address.try(:state),
                     address.try(:zipcode),
                     address.try(:country),
                     address.try(:full_address)]

          # Append custom field values.
          index_case.fields.each do |field|
            data << index_case.send(field.name)
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
