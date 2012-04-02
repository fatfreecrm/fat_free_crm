FactoryGirl.define do
  factory :tag do
    name { Faker::Internet.user_name }
  end
end