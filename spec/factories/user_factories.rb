# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryGirl.define do
  factory :user do
    username            { FactoryGirl.generate(:username) }
    email               { FFaker::Internet.email }
    first_name          { FFaker::Name.first_name }
    last_name           { FFaker::Name.last_name }
    title               { FactoryGirl.generate(:title) }
    company             { FFaker::Company.name }
    alt_email           { FFaker::Internet.email }
    phone               { FFaker::PhoneNumber.phone_number }
    mobile              { FFaker::PhoneNumber.phone_number }
    aim nil
    yahoo nil
    google nil
    skype nil
    admin false
    password_hash       { SecureRandom.hex(64) }
    password_salt       { SecureRandom.hex(64) }
    persistence_token   { SecureRandom.hex(64) }
    perishable_token    { SecureRandom.hex(10) }
    single_access_token nil
    current_login_at    { FactoryGirl.generate(:time) }
    last_login_at       { FactoryGirl.generate(:time) }
    last_login_ip "127.0.0.1"
    current_login_ip "127.0.0.1"
    login_count         { rand(100) + 1 }
    deleted_at nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
    suspended_at nil
    password "password"
    password_confirmation "password"
  end

  factory :admin do
    admin true
  end

  factory :permission do
    user
    asset               { raise "Please specify :asset for the permission" }
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end

  factory :preference do
    user
    name                { raise "Please specify :name for the preference" }
    value               { raise "Please specify :value for the preference" }
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end

  factory :group do
    name                { FFaker::Company.name }
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end
end
