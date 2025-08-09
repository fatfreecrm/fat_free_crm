# frozen_string_literal: true

FactoryBot.define do
  factory :passkey do
    user { nil }
    label { "MyString" }
    external_id { "MyString" }
    public_key { "MyString" }
    sign_count { 1 }
    last_used_at { "2025-08-09 15:30:57" }
  end
end
