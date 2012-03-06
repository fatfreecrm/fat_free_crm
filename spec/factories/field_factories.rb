Factory.sequence :klass_name do |x|
  ["Contact", "Account", "Opportunity", "Lead", "Campaign"].sample
end

Factory.sequence(:field_position) {|x| x }

Factory.sequence :field_label do |x|
  Faker::Internet.user_name + x.to_s
end


Factory.define :field_group do |f|
  f.klass_name          { FactoryGirl.generate(:klass_name) }
  f.label               { FactoryGirl.generate(:field_label) }
  f.tag                 { |f| f.association :tag }
end


Factory.define :field do |f|
  f.type                "Field"
  f.field_group         { Factory.create(:field_group) }
  f.position            { FactoryGirl.generate(:field_position) }
  f.label               { FactoryGirl.generate(:field_label) }
  f.name                { |f| f.label.downcase.gsub(/[^a-z0-9]+/, '_') }
  f.as                  "string"
  f.updated_at          { FactoryGirl.generate(:time) }
  f.created_at          { FactoryGirl.generate(:time) }
end


Factory.define :custom_field, :parent => :field, :class => :custom_field do |f|
  f.type    "CustomField"
end

