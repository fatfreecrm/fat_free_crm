# frozen_string_literal: true

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
    encrypted_password  { SecureRandom.hex(64) }
    password_salt       { SecureRandom.hex(64) }
    last_sign_in_at     { FactoryGirl.generate(:time) }
    current_sign_in_at  { FactoryGirl.generate(:time) }
    last_sign_in_ip "127.0.0.1"
    current_sign_in_ip "127.0.0.1"
    sign_in_count       { rand(100) + 1 }
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
