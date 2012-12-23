FactoryGirl.define do
  factory :opportunity do
    user
    campaign
    account             { FactoryGirl.create(:account) }
    assigned_to         nil
    name                { Faker::Lorem.sentence[0,64] }
    access              "Public"
    source              { %w(campaign cold_call conference online referral self web word_of_mouth other).sample }
    stage               { OPPORTUNITY_STATUSES.sample }
    probability         { rand(50) }
    amount              { rand(1000) }
    discount            { rand(100) }
    closes_on           { FactoryGirl.generate(:date) }
    background_info     { Faker::Lorem.paragraph[0,255] }
    deleted_at          nil
    updated_at          { FactoryGirl.generate(:time) }
    created_at          { FactoryGirl.generate(:time) }
  end

  factory :opportunity_in_pipeline, :parent => :opportunity do
    stage { OPPORTUNITY_STATUSES.sample }
  end

  factory :open_opportunity, :parent => :opportunity do
    stage { OPPORTUNITY_STATUSES.sample }
  end
end
