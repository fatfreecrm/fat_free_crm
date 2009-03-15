require "faker"

Factory.sequence :uuid do |x|
  "%08x-%04x-%04x-%04x-%012x" % [ rand(12345678), rand(1234), rand(1234), rand(1234), rand(123456789012) ]
end

Factory.sequence :address do |x|
  Faker::Address.street_address + " " + Faker::Address.secondary_address + "\n"
  Faker::Address.city + ", " + Faker::Address.us_state_abbr + " " + Faker::Address.zip_code
end

Factory.sequence :website do |x|
  "http://www." + Faker::Internet.domain_name
end

Factory.sequence :title do |x|
  [ "", "Director", "Sales Manager",  "Executive Assistant", "Marketing Manager", "Project Manager", "Product Manager", "Engineer" ].rand
end

Factory.sequence :time do |x|
  Time.now - x.hours
end

Factory.sequence :date do |x|
  Date.today - x.days
end

#----------------------------------------------------------------------------
Factory.define :account do |a|
  # a.uuid                { Factory.next(:uuid) }
  a.user                { |a| a.association(:user) } 
  a.assigned_to         { rand(5) + 1 }
  a.name                { Faker::Company.name }
  a.access              "Public"
  a.website             { Factory.next(:website) }
  a.tall_free_phone     { Faker::PhoneNumber.phone_number }
  a.phone               { Faker::PhoneNumber.phone_number }
  a.fax                 { Faker::PhoneNumber.phone_number }
  a.billing_address     { Factory.next(:address) }
  a.shipping_address    { Factory.next(:address) }
  a.deleted_at          nil
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :account_contact do |a|
  a.account             { |a| a.association(:account) }
  a.contact             { |a| a.association(:contact) }
  a.deleted_at          nil
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :account_opportunity do |a|
  a.account             { |a| a.association(:account) }
  a.opportunity         { |a| a.association(:opportunity) }
  a.deleted_at          nil
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :campaign do |c|
  # c.uuid                { Factory.next(:uuid) }
  c.user                { |a| a.association(:user) }
  c.name                { Faker::Lorem.sentence }
  c.assigned_to         1
  c.access              "Public"
  c.status              { %w(planned started completed planned started completed on_hold called_off).rand }
  c.budget              { rand(500) }
  c.target_leads        { rand(200) }
  c.target_conversion   { rand(20) }
  c.target_revenue      { rand(1000) }
  c.leads_count         { rand(200) }
  c.opportunities_count { rand(20) }
  c.revenue             { rand(1000) }
  c.ends_on             { Factory.next(:date) }
  c.starts_on           { Factory.next(:date) }
  c.objectives          { Faker::Lorem::paragraph }
  c.deleted_at          nil
  c.updated_at          { Factory.next(:time) }
  c.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :comment do |c|
  # c.uuid                { Factory.next(:uuid) }
  c.user                { |a| a.association(:user) }
  c.commentable         { raise "Please specify :commentable for the comment" }
  c.title               { Factory.next(:title) }
  c.private             false
  c.comment             { Faker::Lorem::paragraph }
  c.updated_at          { Factory.next(:time) }
  c.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :contact do |c|
  # c.uuid                { Factory.next(:uuid) }
  c.user                { |a| a.association(:user) }
  c.lead                { |a| a.association(:lead) }
  c.assigned_to         1
  c.reports_to          1
  c.first_name          { Faker::Name.first_name }
  c.last_name           { Faker::Name.last_name }
  c.access              "Public"
  c.title               { Factory.next(:title) }
  c.department          { Faker::Name.name + " Dept." }
  c.source              { %w(campaign cold_call conference online referral self web word_of_mouth other).rand }
  c.email               { Faker::Internet.email }
  c.alt_email           { Faker::Internet.email }
  c.phone               { Faker::PhoneNumber.phone_number }
  c.mobile              { Faker::PhoneNumber.phone_number }
  c.fax                 { Faker::PhoneNumber.phone_number }
  c.blog                { Factory.next(:website) }
  c.facebook            { Factory.next(:website) }
  c.linkedin            { Factory.next(:website) }
  c.twitter             { Factory.next(:website) }
  c.do_not_call         false
  c.address             { Factory.next(:address) }
  c.born_on             "1992-10-10"
  c.deleted_at          nil
  c.updated_at          { Factory.next(:time) }
  c.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :contact_opportunity do |c|
  c.contact             { |a| a.association(:contact) }
  c.opportunity         { |a| a.association(:opportunity) }
  c.role                "foo"
  c.deleted_at          nil
  c.updated_at          { Factory.next(:time) }
  c.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :lead do |l|
  # l.uuid                { Factory.next(:uuid) }
  l.user                { |a| a.association(:user) }
  l.campaign            { |a| a.association(:campaign) }
  l.assigned_to         1
  l.first_name          { Faker::Name.first_name }
  l.last_name           { Faker::Name.last_name }
  l.access              "Public"
  l.company             { Faker::Company.name }
  l.title               { Factory.next(:title) }
  l.source              { %w(campaign cold_call conference online referral self web word_of_mouth other).rand }
  l.status              { %w(new contacted converted rejected).rand }
  l.rating              1
  l.referred_by         { Faker::Name.name }
  l.do_not_call         false
  l.blog                { Factory.next(:website) }
  l.linkedin            { Factory.next(:website) }
  l.facebook            { Factory.next(:website) }
  l.twitter             { Factory.next(:website) }
  l.email               { Faker::Internet.email }
  l.alt_email           { Faker::Internet.email }
  l.phone               { Faker::PhoneNumber.phone_number }
  l.mobile              { Faker::PhoneNumber.phone_number }
  l.address             { Factory.next(:address) }
  l.deleted_at          nil
  l.updated_at          { Factory.next(:time) }
  l.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :opportunity do |o|
  # o.uuid                { Factory.next(:uuid) }
  o.user                { |a| a.association(:user) }
  o.campaign            { |a| a.association(:campaign) }
  o.assigned_to         1
  o.name                { Faker::Lorem.sentence }
  o.access              "Public"
  o.source              { %w(campaign cold_call conference online referral self web word_of_mouth other).rand }
  o.stage               { %w(prospecting qualification analysis presentation proposal negotiation final_review won lost).rand }
  o.probability         { rand(50) }
  o.amount              { rand(1000) }
  o.discount            { rand(100) }
  o.closes_on           { Factory.next(:date) }
  o.deleted_at          nil
  o.updated_at          { Factory.next(:time) }
  o.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :preference do |p|
  p.user                { |a| a.association(:user) }
  p.name                "foo"
  p.value               "foo"
  p.updated_at          { Factory.next(:time) }
  p.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :setting do |s|
  s.name                "foo"
  s.value               nil
  s.default_value       nil
  s.updated_at          { Factory.next(:time) }
  s.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :task do |t|
  # t.uuid                { Factory.next(:uuid) }
  t.user                { |a| a.association(:user) }
  t.asset               { raise "Please specify :asset for the task" }
  t.assigned_to         1
  t.name                { Faker::Lorem.sentence }
  t.priority            nil
  t.category            { %w(call email folowup lunch meeting money presentation trip).rand }
  t.due_at_hint         { raise "Please specify :due_at_hint for the task" }
  t.due_at              { Factory.next(:time) }
  t.completed_at        nil
  t.deleted_at          nil
  t.updated_at          { Factory.next(:time) }
  t.created_at          { Factory.next(:time) }
end

#----------------------------------------------------------------------------
Factory.define :user do |u|
  # u.uuid                { Factory.next(:uuid) }
  u.username            { Faker::Internet.user_name }
  u.email               { Faker::Internet.email }
  u.first_name          { Faker::Name.first_name }
  u.last_name           { Faker::Name.last_name }
  u.title               { Factory.next(:title) }
  u.company             { Faker::Company.name }
  u.alt_email           { Faker::Internet.email }
  u.phone               { Faker::PhoneNumber.phone_number }
  u.mobile              { Faker::PhoneNumber.phone_number }
  u.aim                 nil
  u.yahoo               nil
  u.google              nil
  u.skype               nil
  u.password_hash       "56d91c9f1a9c549304768982fd4e2d8bc2700b403b4524c0f14136dbbe2ce4cd923156ad69f9acce8305dba4e63faa884e61fb7a256cf8f5fc7c2ce176e68e8f"
  u.password_salt       "ce6e0200c96f4dd326b91f3967115a31421a0e7dcddc9ffb63a77f598a9fcb5326fe532dbd9836a2446e46840d398fa32c81f8f4da1a0fcfe931989e9639a013"
  u.remember_token      "d7cdeffd3625f7cb265b21126b85da7c930d47c4a708365c20eb857560055a6b57c9775becb8a957dfdb46df8aee17eb120a011b380e9cc0882f9dfaa2b7ba26"
  u.perishable_token    "TarXlrOPfaokNOzls2U8"
  u.openid_identifier   nil
  u.last_request_at     { Factory.next(:time) }
  u.current_login_at    { Factory.next(:time) }
  u.last_login_at       { Factory.next(:time) }
  u.last_login_ip       "127.0.0.1"
  u.current_login_ip    "127.0.0.1"
  u.login_count         { rand(100) }
  u.deleted_at          nil
  u.updated_at          { Factory.next(:time) }
  u.created_at          { Factory.next(:time) }
  u.password              "aaron"
  u.password_confirmation "aaron"
end

# Load default settings from config/settings.yml file.
#----------------------------------------------------------------------------
Factory.define :default_settings, :parent => :setting do |s|

  # Truncate settings so that we always start with empty table.
  if ActiveRecord::Base.connection.adapter_name.downcase == "mysql"
    ActiveRecord::Base.connection.execute("TRUNCATE settings")
  else # sqlite
    ActiveRecord::Base.connection.execute("DELETE FROM settings")
  end

  settings = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")
  settings.keys.each do |key|
    Factory.define key.to_sym, :parent => :setting do |factory|
      factory.name key
      factory.default_value Base64.encode64(Marshal.dump(settings[key]))
    end
    Factory(key.to_sym) # <--- That's where the data gets loaded.
  end
end
