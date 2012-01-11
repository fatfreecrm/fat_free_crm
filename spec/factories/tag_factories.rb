Factory.define :tag do |t|
  t.name { Faker::Internet.user_name }
end

