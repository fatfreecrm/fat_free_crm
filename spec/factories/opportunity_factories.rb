# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  sequence :opportunity_status do |_s|
    %w[prospecting analysis presentation proposal negotiation final_review won lost].sample
  end

  sequence :opportunity_open_status do |_s|
    %w[prospecting analysis presentation proposal negotiation final_review].sample
  end

  factory :opportunity do
    user
    campaign
    account
    assigned_to         { nil }
    name                { FFaker::Lorem.sentence[0, 64] }
    access              { "Public" }
    source              { %w[campaign cold_call conference online referral self web word_of_mouth other].sample }
    stage               { FactoryBot.generate(:opportunity_status) }
    probability         { rand(50) }
    amount              { rand(1000) }
    discount            { rand(100) }
    closes_on           { FactoryBot.generate(:date) }
    background_info     { FFaker::Lorem.paragraph[0, 255] }
    deleted_at          { nil }
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end

  factory :opportunity_in_pipeline, parent: :opportunity do
    stage               { FactoryBot.generate(:opportunity_open_status) }
  end
end
