# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  sequence :klass_name do |_x|
    %w[Contact Account Opportunity Lead Campaign].sample
  end

  sequence(:field_position) { |x| x }

  sequence :field_label do |x|
    FFaker::Internet.user_name + x.to_s
  end

  factory :field_group do
    klass_name          { FactoryBot.generate(:klass_name) }
    label               { FactoryBot.generate(:field_label) }
    tag
  end

  factory :field do
    type "Field"
    field_group
    position            { FactoryBot.generate(:field_position) }
    label               { FactoryBot.generate(:field_label) }
    name                { |f| f.label.downcase.gsub(/[^a-z0-9]+/, '_') }
    as "string"
    minlength           { rand(100) }
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end

  factory :custom_field do
    type "CustomField"
  end
end
