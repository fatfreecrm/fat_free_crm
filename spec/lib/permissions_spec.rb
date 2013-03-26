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
      entity.should respond_to(:permissions)
    end
    it "should add scope called 'my'" do
      UserWithPermission.should respond_to(:my)
    end
  end

  describe "user_ids" do
    before(:each) do
      @entity = UserWithPermission.create(:access => "Shared")
    end
    
    it "should assign permissions to the object" do
      @entity.permissions.size.should == 0
      @entity.update_attribute(:user_ids, ['1','2','3'])
      @entity.permissions.find_all_by_user_id([1,2,3]).size.should == 3
    end
    
    it "should assign permissions with the 'chosen' select box format" do
      @entity.permissions.size.should == 0
      @entity.update_attribute(:user_ids, ['', '1,2,3'])
      @entity.permissions.find_all_by_user_id([1,2,3]).size.should == 3
    end
    
    it "should handle [] permissions" do
      @entity.update_attribute(:user_ids, [])
      @entity.permissions.size.should == 0
    end
    
    it "should replace existing permissions" do
      @entity.permissions << FactoryGirl.create(:permission, :user_id => 1, :asset => @entity)
      @entity.permissions << FactoryGirl.create(:permission, :user_id => 2, :asset => @entity)
      @entity.update_attribute(:user_ids, ['2','3'])
      @entity.permissions.size.should == 2
      @entity.permissions.find_all_by_user_id([1]).size.should == 0
      @entity.permissions.find_all_by_user_id([2]).size.should == 1
      @entity.permissions.find_all_by_user_id([3]).size.should == 1
    end
    
  end
  
  describe "group_ids" do
    before(:each) do
      @entity = UserWithPermission.create(:access => "Shared")
    end
    it "should assign permissions to the object" do
      @entity.permissions.size.should == 0
      @entity.update_attribute(:group_ids, ['1','2','3'])
      @entity.permissions.find_all_by_group_id([1,2,3]).size.should == 3
    end
    
    it "should assign permissions with the 'chosen' select box format" do
      @entity.permissions.size.should == 0
      @entity.update_attribute(:group_ids, ['', '1,2,3'])
      @entity.permissions.find_all_by_group_id([1,2,3]).size.should == 3
    end
    
    it "should handle [] permissions" do
      @entity.update_attribute(:group_ids, [])
      @entity.permissions.size.should == 0
    end
    
    it "should replace existing permissions" do
      @entity.permissions << FactoryGirl.build(:permission, :group_id => 1, :user_id => nil, :asset => @entity)
      @entity.permissions << FactoryGirl.build(:permission, :group_id => 2, :user_id => nil, :asset => @entity)
      @entity.permissions.size.should == 2
      @entity.update_attribute(:group_ids, ['3'])
      @entity.permissions.size.should == 1
      @entity.permissions.find_all_by_group_id([1,2]).size.should == 0
      @entity.permissions.find_all_by_group_id([3]).size.should == 1
    end
  end

  describe "access" do
    before(:each) do
      @entity = UserWithPermission.create
    end
    it "should delete all permissions if access is set to Public" do
      perm = FactoryGirl.create(:permission, :user_id => 1, :asset => @entity)
      perm.should_receive(:destroy)
      Permission.should_receive(:find_all_by_asset_id_and_asset_type).with(@entity.id, @entity.class).and_return([perm])
      @entity.update_attribute(:access, 'Public')
    end
    it "should delete all permissions if access is set to Private" do
      perm = FactoryGirl.create(:permission, :user_id => 1, :asset => @entity)
      perm.should_receive(:destroy)
      Permission.should_receive(:find_all_by_asset_id_and_asset_type).with(@entity.id, @entity.class).and_return([perm])
      @entity.update_attribute(:access, 'Private')
    end
    it "should not remove permissions if access is set to Shared" do
      perm = FactoryGirl.create(:permission, :user_id => 1, :asset => @entity)
      perm.should_not_receive(:destroy)
      @entity.permissions << perm
      Permission.should_not_receive(:find_all_by_asset_id)
      @entity.update_attribute(:access, 'Shared')
      @entity.permissions.size.should == 1
    end
  end

  describe "save_with_permissions" do
    it "should raise deprecation warning and call save" do
      entity = UserWithPermission.new
      ActiveSupport::Deprecation.should_receive(:warn)
      entity.should_receive(:save)
      entity.save_with_permissions
    end
  end
  
  describe "update_with_permissions" do
    it "should raise deprecation warning and call update_attributes" do
      entity = UserWithPermission.new
      ActiveSupport::Deprecation.should_receive(:warn)
      entity.should_receive(:update_attributes).with({})
      entity.update_with_permissions({})
    end
  end

  describe "save_with_model_permissions" do
    it "should copy permissions from original model" do
      entity = UserWithPermission.new
      model = mock_model(Account, :access => "Shared", :user_ids => [1,2,3], :group_ids => [4,5,6])
      entity.should_receive(:access=).with("Shared")
      entity.should_receive(:user_ids=).with([1,2,3])
      entity.should_receive(:group_ids=).with([4,5,6])
      entity.should_receive(:save)
      entity.save_with_model_permissions(model)
    end
  end
    
end
