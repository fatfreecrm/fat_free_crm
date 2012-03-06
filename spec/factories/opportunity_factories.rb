Factory.define :opportunity do |o|
  o.user                { |a| a.association(:user) }
  o.campaign            { |a| a.association(:campaign) }
  o.account             { Factory.create(:account) }
  o.assigned_to         nil
  o.name                { Faker::Lorem.sentence[0,64] }
  o.access              "Public"
  o.source              { %w(campaign cold_call conference online referral self web word_of_mouth other).sample }
  o.stage               { %w(prospecting analysis presentation proposal negotiation final_review won lost).sample }
  o.probability         { rand(50) }
  o.amount              { rand(1000) }
  o.discount            { rand(100) }
  o.closes_on           { FactoryGirl.generate(:date) }
  o.background_info     { Faker::Lorem.paragraph[0,255] }
  o.deleted_at          nil
  o.updated_at          { FactoryGirl.generate(:time) }
  o.created_at          { FactoryGirl.generate(:time) }
end

