# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: permissions
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  asset_id   :integer
#  asset_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Permission do
  before(:each) do
    @valid_attributes = {
      user: mock_model(User),
      asset: mock_model(Account)
    }
  end

  it "should create a new instance given valid attributes" do
    Permission.create!(@valid_attributes)
  end

  it "should validate with group_ids" do
    p = Permission.new group_id: 1
    expect(p).to be_valid
  end

  it "should validate with user_ids" do
    p = Permission.new user_id: 2
    expect(p).to be_valid
  end

  it "should validate not allow group_ids or user_ids to be blank" do
    p = Permission.new
    expect(p).not_to be_valid
    expect(p.errors['user_id']).to eq(["can't be blank"])
    expect(p.errors['group_id']).to eq(["can't be blank"])
  end

  it 'should not allow duplicate records with (user_id, group_id, asset_type, asset_ids) the same' do
    permission1 = Permission.create(user_id: 1, group_id: 1, asset_id: 1, asset_type: 'UserWithPermission')
    permission2 = Permission.new(user_id: 1, group_id: 1, asset_id: 1, asset_type: 'UserWithPermission')

    expect(permission1).to be_valid
    expect(permission2).not_to be_valid
  end
end
