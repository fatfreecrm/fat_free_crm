# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: account_contacts
#
#  id         :integer         not null, primary key
#  account_id :integer
#  contact_id :integer
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AccountContact do
  before(:each) do
    @valid_attributes = {
      account: mock_model(Account),
      contact: mock_model(Contact)
    }
  end

  it "should create a new instance given valid attributes" do
    expect(@valid_attributes[:account]).to receive(:increment!)
    AccountContact.create!(@valid_attributes)
  end
end
