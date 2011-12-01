Factory.sequence :klass_name do |x|
  ["Contact", "Account", "Opportunity", "Lead", "Campaign"].sample
end

Factory.sequence(:field_position) {|x| x }

Factory.sequence :field_name do |x|
  (Faker::Internet.user_name + x.to_s).gsub(/[^a-z0-9_]/, '').gsub(/[_ ]+/, '_')
end


Factory.define :field_group do |f|
  f.klass_name          { Factory.next(:klass_name) }
end


Factory.define :field do |f|
  f.type                "Field"
  f.field_group         { Factory.create(:field_group) }
  f.position            { Factory.next(:field_position) }
  f.name                { Factory.next(:field_name) }
  f.label               {|f| f.name }
  f.as                  "string"
  f.updated_at          { Factory.next(:time) }
  f.created_at          { Factory.next(:time) }
end


Factory.define :custom_field, :parent => :field, :class => :custom_field do |f|
  f.type    "CustomField"
end

