Factory.define :task do |t|
  t.user                { |a| a.association(:user) }
  t.asset               nil
  t.assigned_to         nil
  t.completed_by        nil
  t.name                { Faker::Lorem.sentence[0,64] }
  t.priority            nil
  t.category            { %w(call email follow_up lunch meeting money presentation trip).sample }
  t.bucket              "due_asap"
  t.due_at              { FactoryGirl.generate(:time) }
  t.background_info     { Faker::Lorem.paragraph[0,255] }
  t.completed_at        nil
  t.deleted_at          nil
  t.updated_at          { FactoryGirl.generate(:time) }
  t.created_at          { FactoryGirl.generate(:time) }
end

