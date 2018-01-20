# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  factory :campaign do
    user
    name                { FFaker::Lorem.sentence[0, 64] }
    assigned_to nil
    access "Public"
    status              { %w[planned started completed planned started completed on_hold called_off].sample }
    budget              { rand(500) }
    target_leads        { rand(200) }
    target_conversion   { rand(20) }
    target_revenue      { rand(1000) }
    leads_count         { rand(200) }
    opportunities_count { rand(20) }
    revenue             { rand(1000) }
    ends_on             { FactoryBot.generate(:date) }
    starts_on           { FactoryBot.generate(:date) }
    objectives          { FFaker::Lorem.paragraph[0, 255] }
    background_info     { FFaker::Lorem.paragraph[0, 255] }
    deleted_at nil
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end
end
