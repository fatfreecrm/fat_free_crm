FactoryGirl.define do
  factory :user do
    username            { FactoryGirl.generate(:username) }
    email               { Faker::Internet.email }
    first_name          { Faker::Name.first_name }
    last_name           { Faker::Name.last_name }
    title               { FactoryGirl.generate(:title) }
    company             { Faker::Company.name }
    alt_email           { Faker::Internet.email }
    phone               { Faker::PhoneNumber.phone_number }
    mobile              { Faker::PhoneNumber.phone_number }
    aim                 nil
    yahoo               nil
    google              nil
    skype               nil
    admin               false
    password_hash       "56d91c9f1a9c549304768982fd4e2d8bc2700b403b4524c0f14136dbbe2ce4cd923156ad69f9acce8305dba4e63faa884e61fb7a256cf8f5fc7c2ce176e68e8f"
    password_salt       "ce6e0200c96f4dd326b91f3967115a31421a0e7dcddc9ffb63a77f598a9fcb5326fe532dbd9836a2446e46840d398fa32c81f8f4da1a0fcfe931989e9639a013"
    authentication_token nil
    last_request_at     { FactoryGirl.generate(:time) }
    current_sign_in_at  { FactoryGirl.generate(:time) }
    last_sign_in_at     { FactoryGirl.generate(:time) }
    last_sign_in_ip     "127.0.0.1"
    current_sign_in_ip  "127.0.0.1"
    sign_in_count       { rand(100) + 1 }
    deleted_at          nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
    suspended_at        nil
    password              "password"
    password_confirmation "password"
  end


  factory :admin do
    admin               true
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
    name                { Faker::Company.name }
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end
end
