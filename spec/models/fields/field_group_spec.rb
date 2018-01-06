# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: field_groups
#
#  id         :integer         not null, primary key
#  name       :string(64)
#  label      :string(128)
#  position   :integer
#  hint       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  tag_id     :integer
#  klass_name :string(32)
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe FieldGroup do
  it "should have field metadata" do
    expect(FieldGroup.new).to respond_to(:fields)
  end
end
