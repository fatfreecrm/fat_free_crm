# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: contact_opportunities
#
#  id             :integer         not null, primary key
#  contact_id     :integer
#  opportunity_id :integer
#  role           :string(32)
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ContactOpportunity do
  before(:each) do
    @valid_attributes = {
      contact: mock_model(Contact),
      opportunity: mock_model(Opportunity)
    }
  end

  it "should create a new instance given valid attributes" do
    ContactOpportunity.create!(@valid_attributes)
  end
end
