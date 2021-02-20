# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: importers
#
#  id                       :integer         not null, primary key
#  entity_type              :string
#  entity_id                :integer
#  attachment_file_size    :integer
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  status                  :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.describe Importer, type: :model do
  it "should create a new instance given valid attributes" do
    Importer.create!(attributes_for(:importer))
  end

  describe "validates" do
    it "attachment" do
      is_expected.to have_attached_file(:attachment)
    end

    it "attachment presence" do
      is_expected.to validate_attachment_presence(:attachment)
    end

    xit "attachment file size" do
      is_expected.to validate_attachment_size(:attachment)
        .less_than(10.megabytes)
    end

    it "attachment content type" do
      is_expected.to validate_attachment_content_type(:attachment)
        .allowing('text/xml', 'application/xml',
                  'application/vnd.ms-excel', 'application/x-ole-storage',
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        .rejecting('text/plain')
    end
  end
end
