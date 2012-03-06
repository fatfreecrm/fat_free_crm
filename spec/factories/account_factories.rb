Factory.define :account do |a|
  a.user                { |a| a.association(:user) }
  a.assigned_to         nil
  a.name                { Faker::Company.name }
  a.access              "Public"
  a.website             { FactoryGirl.generate(:website) }
  a.email               { Faker::Internet.email }
  a.toll_free_phone     { Faker::PhoneNumber.phone_number }
  a.phone               { Faker::PhoneNumber.phone_number }
  a.fax                 { Faker::PhoneNumber.phone_number }
  a.background_info     { Faker::Lorem.paragraph[0,255] }
  a.deleted_at          nil
  a.updated_at          { FactoryGirl.generate(:time) }
  a.created_at          { FactoryGirl.generate(:time) }
end


Factory.define :account_contact do |a|
  a.account             { |a| a.association(:account) }
  a.contact             { |a| a.association(:contact) }
  a.deleted_at          nil
  a.updated_at          { FactoryGirl.generate(:time) }
  a.created_at          { FactoryGirl.generate(:time) }
end


Factory.define :account_opportunity do |a|
  a.account             { |a| a.association(:account) }
  a.opportunity         { |a| a.association(:opportunity) }
  a.deleted_at          nil
  a.updated_at          { FactoryGirl.generate(:time) }
  a.created_at          { FactoryGirl.generate(:time) }
end

