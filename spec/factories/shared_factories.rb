# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  factory :version do
    whodunnit ""
    item                { raise "Please specify :item for the version" }
    event "create"
    created_at          { FactoryBot.generate(:time) }
  end

  factory :comment do
    user
    commentable         { raise "Please specify :commentable for the comment" }
    title               { FactoryBot.generate(:title) }
    private false
    comment             { FFaker::Lorem.paragraph }
    state "Expanded"
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end

  factory :email do
    imap_message_id     { format("%08x", rand(0xFFFFFFFF)) }
    user
    mediator            { raise "Please specify :mediator for the email" }
    sent_from           { FFaker::Internet.email }
    sent_to             { FFaker::Internet.email }
    cc                  { FFaker::Internet.email }
    bcc nil
    subject             { FFaker::Lorem.sentence }
    body                { FFaker::Lorem.paragraph[0, 255] }
    header nil
    sent_at             { FactoryBot.generate(:time) }
    received_at         { FactoryBot.generate(:time) }
    deleted_at nil
    state "Expanded"
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end

  factory :address do
    addressable         { raise "Please specify :addressable for the address" }
    street1             { FFaker::Address.street_address }
    street2             { FFaker::Address.street_address }
    city                { FFaker::Address.city }
    state               { FFaker::AddressUS.state_abbr }
    zipcode             { FFaker::AddressUS.zip_code }
    country             { FFaker::AddressUK.country }
    full_address        { FactoryBot.generate(:address) }
    address_type        { %w[Business Billing Shipping].sample }
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
    deleted_at nil
  end

  factory :avatar do
    user
    entity              { raise "Please specify :entity for the avatar" }
    image               { File.new(Rails.root.join('spec', 'fixtures', 'rails.png')) }
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end
end
