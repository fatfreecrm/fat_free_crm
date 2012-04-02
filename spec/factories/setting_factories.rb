FactoryGirl.define do
  factory :setting do
    name                "foo"
    value               nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end
end