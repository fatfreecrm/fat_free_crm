# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: account_opportunities
#
#  id             :integer         not null, primary key
#  account_id     :integer
#  opportunity_id :integer
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe AccountOpportunity do
  before do
    @valid_attributes = {
      account: mock_model(Account),
      opportunity: mock_model(Opportunity)
    }
  end

  it "should create a new instance given valid attributes" do
    AccountOpportunity.create!(@valid_attributes)
  end
end

