Factory.define :setting do |s|
  s.name                "foo"
  s.value               nil
  s.updated_at          { FactoryGirl.generate(:time) }
  s.created_at          { FactoryGirl.generate(:time) }
end

