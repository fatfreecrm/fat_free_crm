# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryGirl.define do
  factory :contact do
    user
    lead
    assigned_to nil
    reports_to nil
    first_name          { FFaker::Name.first_name }
    last_name           { FFaker::Name.last_name }
    access "Public"
    title               { FactoryGirl.generate(:title) }
    department          { FFaker::Name.name + " Dept." }
    source              { %w(campaign cold_call conference online referral self web word_of_mouth other).sample }
    email               { FFaker::Internet.email }
    alt_email           { FFaker::Internet.email }
    phone               { FFaker::PhoneNumber.phone_number }
    mobile              { FFaker::PhoneNumber.phone_number }
    fax                 { FFaker::PhoneNumber.phone_number }
    blog                { FactoryGirl.generate(:website) }
    facebook            { FactoryGirl.generate(:website) }
    linkedin            { FactoryGirl.generate(:website) }
    twitter             { FactoryGirl.generate(:website) }
    do_not_call false
    born_on "1992-10-10"
    background_info     { FFaker::Lorem.paragraph[0, 255] }
    deleted_at nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end

  factory :contact_opportunity do
    contact
    opportunity
    role "foo"
    deleted_at nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end
end
