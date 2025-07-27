# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module ContactsHelper
  # Contact summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def contact_summary(contact)
    summary = ['']
    summary << contact.title.titleize if contact.title?
    summary << contact.department if contact.department?
    summary.last += " #{t(:at)} #{contact.account.name}" if contact.account&.name?
    summary << contact.email if contact.email.present?
    summary << "#{t(:phone_small)}: #{contact.phone}" if contact.phone.present?
    summary << "#{t(:mobile_small)}: #{contact.mobile}" if contact.mobile.present?
    summary.join(', ')
  end

  def vcard_for(contact)
    card = VCardigan.create
    card.name contact.last_name, contact.first_name
    card.fullname "#{contact.first_name} #{contact.last_name}"
    card.title contact.title if contact.title.present?
    if contact.respond_to?(:account) # Contact
      card.org contact.account.name, contact.department if contact.account.present?
    elsif contact.respond_to?(:company) # Lead
      card.org contact.company if contact.company.present?
    end
    card.email contact.email, type: %w[internet work] if contact.email.present?
    card.email contact.alt_email, type: %w[internet work] if contact.alt_email.present?
    card.tel contact.phone, type: 'work' if contact.phone?
    card.tel contact.mobile, type: %w[cell voice] if contact.mobile.present?
    card.note "Exported from Fat Free CRM"

    if contact.business_address
      card.adr contact.business_address.street1,
               contact.business_address.street2,
               contact.business_address.city,
               contact.business_address.state,
               contact.business_address.zipcode,
               contact.business_address.country, type: 'work'
    end

    card
  end
end
