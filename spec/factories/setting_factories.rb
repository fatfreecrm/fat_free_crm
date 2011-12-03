Factory.define :setting do |s|
  s.name                "foo"
  s.value               nil
  s.default_value       nil
  s.updated_at          { Factory.next(:time) }
  s.created_at          { Factory.next(:time) }
end

