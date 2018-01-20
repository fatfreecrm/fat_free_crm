# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  factory :lead do
    user
    campaign
    assigned_to nil
    first_name          { FFaker::Name.first_name }
    last_name           { FFaker::Name.last_name }
    access "Public"
    company             { FFaker::Company.name }
    title               { FactoryBot.generate(:title) }
    source              { %w[campaign cold_call conference online referral self web word_of_mouth other].sample }
    status              { %w[new contacted converted rejected].sample }
    rating 1
    referred_by         { FFaker::Name.name }
    do_not_call false
    blog                { FactoryBot.generate(:website) }
    linkedin            { FactoryBot.generate(:website) }
    facebook            { FactoryBot.generate(:website) }
    twitter             { FactoryBot.generate(:website) }
    email               { FFaker::Internet.email }
    alt_email           { FFaker::Internet.email }
    phone               { FFaker::PhoneNumber.phone_number }
    mobile              { FFaker::PhoneNumber.phone_number }
    background_info     { FFaker::Lorem.paragraph[0, 255] }
    deleted_at nil
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end
end
