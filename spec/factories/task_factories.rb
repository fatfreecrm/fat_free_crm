# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  factory :task do
    user
    asset               { nil }
    assigned_to         { nil }
    completed_by        { nil }
    name                { FFaker::Lorem.sentence[0, 64] }
    priority            { nil }
    category            { %w[call email follow_up lunch meeting money presentation trip].sample }
    bucket              { "due_asap" }
    due_at              { FactoryBot.generate(:time) }
    background_info     { FFaker::Lorem.paragraph[0, 255] }
    completed_at        { nil }
    deleted_at          { nil }
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end

  factory :completed_task, parent: :task do
    completed_at { Date.yesterday }
  end
end
