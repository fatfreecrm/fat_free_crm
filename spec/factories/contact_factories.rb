Factory.define :contact do |c|
  c.user                { |a| a.association(:user) }
  c.lead                { |a| a.association(:lead) }
  c.assigned_to         nil
  c.reports_to          nil
  c.first_name          { Faker::Name.first_name }
  c.last_name           { Faker::Name.last_name }
  c.access              "Public"
  c.title               { FactoryGirl.generate(:title) }
  c.department          { Faker::Name.name + " Dept." }
  c.source              { %w(campaign cold_call conference online referral self web word_of_mouth other).sample }
  c.email               { Faker::Internet.email }
  c.alt_email           { Faker::Internet.email }
  c.phone               { Faker::PhoneNumber.phone_number }
  c.mobile              { Faker::PhoneNumber.phone_number }
  c.fax                 { Faker::PhoneNumber.phone_number }
  c.blog                { FactoryGirl.generate(:website) }
  c.facebook            { FactoryGirl.generate(:website) }
  c.linkedin            { FactoryGirl.generate(:website) }
  c.twitter             { FactoryGirl.generate(:website) }
  c.do_not_call         false
  c.born_on             "1992-10-10"
  c.background_info     { Faker::Lorem.paragraph[0,255] }
  c.deleted_at          nil
  c.updated_at          { FactoryGirl.generate(:time) }
  c.created_at          { FactoryGirl.generate(:time) }
end


Factory.define :contact_opportunity do |c|
  c.contact             { |a| a.association(:contact) }
  c.opportunity         { |a| a.association(:opportunity) }
  c.role                "foo"
  c.deleted_at          nil
  c.updated_at          { FactoryGirl.generate(:time) }
  c.created_at          { FactoryGirl.generate(:time) }
end

