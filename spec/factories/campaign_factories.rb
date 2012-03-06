Factory.define :campaign do |c|
  c.user                { |a| a.association(:user) }
  c.name                { Faker::Lorem.sentence[0,64] }
  c.assigned_to         nil
  c.access              "Public"
  c.status              { %w(planned started completed planned started completed on_hold called_off).sample }
  c.budget              { rand(500) }
  c.target_leads        { rand(200) }
  c.target_conversion   { rand(20) }
  c.target_revenue      { rand(1000) }
  c.leads_count         { rand(200) }
  c.opportunities_count { rand(20) }
  c.revenue             { rand(1000) }
  c.ends_on             { FactoryGirl.generate(:date) }
  c.starts_on           { FactoryGirl.generate(:date) }
  c.objectives          { Faker::Lorem.paragraph[0,255] }
  c.background_info     { Faker::Lorem.paragraph[0,255] }
  c.deleted_at          nil
  c.updated_at          { FactoryGirl.generate(:time) }
  c.created_at          { FactoryGirl.generate(:time) }
end

