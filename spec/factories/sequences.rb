Factory.sequence :address do |x|
  Faker::Address.street_address + " " + Faker::Address.secondary_address + "\n"
  Faker::Address.city + ", " + Faker::Address.us_state_abbr + " " + Faker::Address.zip_code
end

Factory.sequence :username do |x|
  Faker::Internet.user_name + x.to_s  # make sure it's unique by appending sequence number
end

Factory.sequence :website do |x|
  "http://www." + Faker::Internet.domain_name
end

Factory.sequence :title do |x|
  [ "", "Director", "Sales Manager",  "Executive Assistant", "Marketing Manager", "Project Manager", "Product Manager", "Engineer" ].sample
end

Factory.sequence :time do |x|
  Time.now - x.hours
end

Factory.sequence :date do |x|
  Date.today - x.days
end
