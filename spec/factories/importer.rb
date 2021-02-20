# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  factory :importer do
    entity_type             { :lead }
    entity_id               { 1 }
    attachment_file_size    { Random.rand(1..1024) }
    attachment_file_name    { "#{FFaker::Filesystem.file_name}.#{%w[xls xlsx].sample}" }
    attachment_content_type { %w[text/xml application/xml].sample }
    status                  { FFaker::Lorem.word }
    created_at              { FactoryBot.generate(:time) }
    updated_at              { FactoryBot.generate(:time) }
  end
end
