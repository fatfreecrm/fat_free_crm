# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FatFreeCRM::Permissions do
  before :each do
    build_model(:user_with_permission) do
      uses_user_permissions
      string :access
    end
  end

  describe "initialization" do
    it "should add 'has_many permissions' to the model" do
      entity = UserWithPermission.new
      expect(entity).to respond_to(:permissions)
    end
    it "should add scope called 'my'" do
      expect(UserWithPermission).to respond_to(:my)
    end
  end

  describe "user_ids" do
    before(:each) do
      @entity = UserWithPermission.create(access: "Shared")
    end

    it "should assign permissions to the object" do
      expect(@entity.permissions.size).to eq(0)
      @entity.user_ids = %w[1 2 3]
      @entity.save!
      expect(@entity.permissions.where(user_id: [1, 2, 3]).size).to eq(3)
    end

    it "should handle [] permissions" do
      @entity.user_ids = []
      @entity.save!
      expect(@entity.permissions.size).to eq(0)
    end

    it "should replace existing permissions" do
      @entity.permissions << create(:permission, user_id: 1, asset: @entity)
      @entity.permissions << create(:permission, user_id: 2, asset: @entity)
      @entity.user_ids = %w[2 3]
      @entity.save!
      expect(@entity.permissions.size).to eq(2)
      expect(@entity.permissions.where(user_id: [1]).size).to eq(0)
      expect(@entity.permissions.where(user_id: [2]).size).to eq(1)
      expect(@entity.permissions.where(user_id: [3]).size).to eq(1)
    end
  end

  describe "group_ids" do
    before(:each) do
      @entity = UserWithPermission.create(access: "Shared")
    end
    it "should assign permissions to the object" do
      expect(@entity.permissions.size).to eq(0)
      @entity.group_ids = %w[1 2 3]
      @entity.save!
      expect(@entity.permissions.where(group_id: [1, 2, 3]).size).to eq(3)
    end

    it "should handle [] permissions" do
      @entity.group_ids = []
      @entity.save!
      expect(@entity.permissions.size).to eq(0)
    end

    it "should replace existing permissions" do
      @entity.permissions << build(:permission, group_id: 1, user_id: nil, asset: @entity)
      @entity.permissions << build(:permission, group_id: 2, user_id: nil, asset: @entity)
      expect(@entity.permissions.size).to eq(2)
      @entity.group_ids = ['3']
      @entity.save!
      expect(@entity.permissions.size).to eq(1)
      expect(@entity.permissions.where(group_id: [1, 2]).size).to eq(0)
      expect(@entity.permissions.where(group_id: [3]).size).to eq(1)
    end
  end

  describe "access" do
    before(:each) do
      @entity = UserWithPermission.create
    end
    it "should delete all permissions if access is set to Public" do
      perm = create(:permission, user_id: 1, asset: @entity)
      expect(perm).to receive(:destroy)
      expect(Permission).to receive(:where).with(asset_id: @entity.id, asset_type: @entity.class.to_s).and_return([perm])
      @entity.update_attribute(:access, 'Public')
    end
    it "should delete all permissions if access is set to Private" do
      perm = create(:permission, user_id: 1, asset: @entity)
      expect(perm).to receive(:destroy)
      expect(Permission).to receive(:where).with(asset_id: @entity.id, asset_type: @entity.class.to_s).and_return([perm])
      @entity.update_attribute(:access, 'Private')
    end
    it "should not remove permissions if access is set to Shared" do
      perm = create(:permission, user_id: 1, asset: @entity)
      expect(perm).not_to receive(:destroy)
      @entity.permissions << perm
      expect(Permission).not_to receive(:find_all_by_asset_id)
      @entity.update_attribute(:access, 'Shared')
      expect(@entity.permissions.size).to eq(1)
    end
  end

  describe "save_with_model_permissions" do
    it "should copy permissions from original model" do
      entity = UserWithPermission.new
      model = mock_model(Account, access: "Shared", user_ids: [1, 2, 3], group_ids: [4, 5, 6])
      expect(entity).to receive(:access=).with("Shared")
      expect(entity).to receive(:user_ids=).with([1, 2, 3])
      expect(entity).to receive(:group_ids=).with([4, 5, 6])
      expect(entity).to receive(:save)
      entity.save_with_model_permissions(model)
    end
  end

  describe 'remove_permissions' do
    context 'with a new record' do
      before :each do
        @entity = UserWithPermission.new
      end
      it 'should have no relationships to destroy' do
        expect(@entity.remove_permissions).to eq []
      end
    end

    context 'with an existing record' do
      before :each do
        @entity = UserWithPermission.create

        @permission1 = Permission.create(user_id: 1, group_id: 1, asset_id: @entity.id, asset_type: 'UserWithPermission')
        @permission2 = Permission.create(user_id: 1, group_id: 2, asset_id: @entity.id, asset_type: 'UserWithPermission')
      end
      it 'should remove the related permissions' do
        current = Permission.all.count

        expect(@entity.remove_permissions.length).to eq 2
        expect(Permission.all.count).to eq(current - 2)
      end
    end
  end
end
