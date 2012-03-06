Factory.define :activity do |a|
  a.user                { |a| a.association(:user) }
  a.subject             { raise "Please specify :subject for the activity" }
  a.action              nil
  a.info                nil
  a.private             false
  a.updated_at          { FactoryGirl.generate(:time) }
  a.created_at          { FactoryGirl.generate(:time) }
end


Factory.define :comment do |c|
  c.user                { |a| a.association(:user) }
  c.commentable         { raise "Please specify :commentable for the comment" }
  c.title               { FactoryGirl.generate(:title) }
  c.private             false
  c.comment             { Faker::Lorem::paragraph }
  c.state               "Expanded"
  c.updated_at          { FactoryGirl.generate(:time) }
  c.created_at          { FactoryGirl.generate(:time) }
end


Factory.define :email do |e|
  e.imap_message_id     { "%08x" % rand(0xFFFFFFFF) }
  e.user                { |a| a.association(:user) }
  e.mediator            { raise "Please specify :mediator for the email" }
  e.sent_from           { Faker::Internet.email }
  e.sent_to             { Faker::Internet.email }
  e.cc                  { Faker::Internet.email }
  e.bcc                 nil
  e.subject             { Faker::Lorem.sentence }
  e.body                { Faker::Lorem.paragraph[0,255] }
  e.header              nil
  e.sent_at             { FactoryGirl.generate(:time) }
  e.received_at         { FactoryGirl.generate(:time) }
  e.deleted_at          nil
  e.state               "Expanded"
  e.updated_at          { FactoryGirl.generate(:time) }
  e.created_at          { FactoryGirl.generate(:time) }
end


Factory.define :address do |a|
  a.addressable         { raise "Please specify :addressable for the address" }
  a.street1             { Faker::Address.street_address }
  a.street2             { Faker::Address.street_address }
  a.city                { Faker::Address.city }
  a.state               { Faker::Address.us_state_abbr }
  a.zipcode             { Faker::Address.zip_code }
  a.country             { Faker::Address.uk_country }
  a.full_address        { FactoryGirl.generate(:address) }
  a.address_type        { %w(Business Billing Shipping).sample }
  a.updated_at          { FactoryGirl.generate(:time) }
  a.created_at          { FactoryGirl.generate(:time) }
  a.deleted_at          nil
end


Factory.define :avatar do |a|
  a.user                { |a| a.association(:user) }
  a.entity              { raise "Please specify :entity for the avatar" }
  a.image_file_size     nil
  a.image_file_name     nil
  a.image_content_type  nil
  a.updated_at          { FactoryGirl.generate(:time) }
  a.created_at          { FactoryGirl.generate(:time) }
end

