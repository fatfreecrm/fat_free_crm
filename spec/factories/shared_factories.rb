# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryGirl.define do
  factory :version do
    whodunnit           ""
    item                { raise "Please specify :item for the version" }
    event               "create"
    created_at          { FactoryGirl.generate(:time) }
  end


  factory :comment do
    user
    commentable         { raise "Please specify :commentable for the comment" }
    title               { FactoryGirl.generate(:title) }
    private             false
    comment             { Faker::Lorem::paragraph }
    state               "Expanded"
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end


  factory :email do
    imap_message_id     { "%08x" % rand(0xFFFFFFFF) }
    user
    mediator            { raise "Please specify :mediator for the email" }
    sent_from           { Faker::Internet.email }
    sent_to             { Faker::Internet.email }
    cc                  { Faker::Internet.email }
    bcc                 nil
    subject             { Faker::Lorem.sentence }
    body                { Faker::Lorem.paragraph[0,255] }
    header              nil
    sent_at             { FactoryGirl.generate(:time) }
    received_at         { FactoryGirl.generate(:time) }
    deleted_at          nil
    state               "Expanded"
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end


  factory :address do
    addressable         { raise "Please specify :addressable for the address" }
    street1             { Faker::Address.street_address }
    street2             { Faker::Address.street_address }
    city                { Faker::Address.city }
    state               { Faker::Address.us_state_abbr }
    zipcode             { Faker::Address.zip_code }
    country             { Faker::Address.uk_country }
    full_address        { FactoryGirl.generate(:address) }
    address_type        { %w(Business Billing Shipping).sample }
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
    deleted_at          nil
  end


  factory :avatar do
    user
    entity              { raise "Please specify :entity for the avatar" }
    image_file_size     nil
    image_file_name     nil
    image_content_type  nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end
end
