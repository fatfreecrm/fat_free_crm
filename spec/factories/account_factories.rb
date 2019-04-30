# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  factory :account do
    user
    assigned_to         { nil }
    name                { FFaker::Company.name + rand(100).to_s }
    access              { "Public" }
    website             { FactoryBot.generate(:website) }
    email               { FFaker::Internet.email }
    toll_free_phone     { FFaker::PhoneNumber.phone_number }
    phone               { FFaker::PhoneNumber.phone_number }
    fax                 { FFaker::PhoneNumber.phone_number }
    background_info     { FFaker::Lorem.paragraph[0, 255] }
    deleted_at          { nil }
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end

  factory :account_contact do
    account
    contact
    deleted_at          { nil }
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end

  factory :account_opportunity do
    account
    opportunity
    deleted_at          { nil }
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end
end
