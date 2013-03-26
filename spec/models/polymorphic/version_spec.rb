# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: versions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  item_id   :integer
#  item_type :string(255)
#  event       :string(32)      default("create")
#  info         :string(255)     default("")
#  private      :boolean         default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Version, :versioning => true do

  before do
    login
    PaperTrail.whodunnit = current_user.id.to_s
  end

  it "should create a new instance given valid attributes" do
    FactoryGirl.create(:version, :whodunnit => PaperTrail.whodunnit, :item => FactoryGirl.create(:lead))
  end

  describe "with multiple version records" do
    before do
      @lead = FactoryGirl.create(:lead)

      %w(create destroy update view).each do |event|
        FactoryGirl.create(:version, :event => event, :item => @lead, :whodunnit => PaperTrail.whodunnit)
        FactoryGirl.create(:version, :event => event, :item => @lead, :whodunnit => "1")
      end
    end

    it "should not include view events" do
      @versions = Version.for(current_user).exclude_events(:view)
      @versions.map(&:event).sort.should_not include('view')
    end

    it "should exclude create, update and destroy events" do
      @versions = Version.for(current_user).exclude_events(:create, :update, :destroy)
      @versions.map(&:event).should_not include('create')
      @versions.map(&:event).should_not include('update')
      @versions.map(&:event).should_not include('destroy')
    end

    it "should include only destroy events" do
      @versions = Version.for(current_user).include_events(:destroy)
      @versions.map(&:event).uniq.should == %w(destroy)
    end

    it "should include create and update events" do
      @versions = Version.for(current_user).include_events(:create, :update)
      @versions.map(&:event).uniq.sort.should == %w(create update)
    end

    it "should select all versions for a given user" do
      @versions = Version.for(current_user)
      @versions.map(&:whodunnit).uniq.should == [current_user.id.to_s]
    end
  end

  %w(account campaign contact lead opportunity task).each do |item|
    describe "Create, update, and delete (#{item})" do
      before :each do
        @item = FactoryGirl.create(item.to_sym, :user => current_user)
        @conditions = {:item_id => @item.id, :item_type => @item.class.name, :whodunnit => PaperTrail.whodunnit}
      end

      it "should add a version when creating new #{item}" do
        @version = Version.where(@conditions.merge(:event => 'create')).first
        @version.should_not == nil
      end

      it "should add a version when updating existing #{item}" do
        if @item.respond_to?(:full_name)
          @item.update_attributes(:first_name => "Billy", :last_name => "Bones")
        else
          @item.update_attributes(:name => "Billy Bones")
        end
        @version = Version.where(@conditions.merge(:event => 'update')).first

        @version.should_not == nil
      end

      it "should add a version when deleting #{item}" do
        @item.destroy
        @version = Version.where(@conditions.merge(:event => 'destroy')).first

        @version.should_not == nil
      end

      it "should add a version when commenting on a #{item}" do
        @comment = FactoryGirl.create(:comment, :commentable => @item, :user => current_user)

        @version = Version.where({:related_id => @item.id, :related_type => @item.class.name, :whodunnit => PaperTrail.whodunnit, :event => 'create'}).first
        @version.should_not == nil
      end
    end
  end

  describe "Recently viewed items (task)" do
    before do
      @task = FactoryGirl.create(:task)
      @conditions = {:item_id => @task.id, :item_type => @task.class.name}
    end

    it "creating a new task should not add it to recently viewed items list" do
      @versions = Version.where(@conditions)

      @versions.map(&:event).should include('create') # but not view
    end

    it "updating a new task should not add it to recently viewed items list" do
      @task.update_attribute(:updated_at, 1.second.ago)
      @versions = Version.where(@conditions)

      @versions.map(&:event).sort.should == %w(create update) # but not view
    end
  end

  describe "Action refinements for task updates" do
    before do
      @task = FactoryGirl.create(:task, :user => current_user)
      @conditions = {:item_id => @task.id, :item_type => @task.class.name, :whodunnit => PaperTrail.whodunnit}
    end

    it "should create 'completed' task event" do
      @task.update_attribute(:completed_at, 1.second.ago)
      @versions = Version.where(@conditions)

      @versions.map(&:event).should include('complete')
    end

    it "should create 'reassigned' task event" do
      @task.update_attribute(:assigned_to, current_user.id + 1)
      @versions = Version.where(@conditions)

      @versions.map(&:event).should include('reassign')
    end

    it "should create 'rescheduled' task event" do
      @task.update_attribute(:bucket, "due_tomorrow") # FactoryGirl creates :due_asap task
      @versions = Version.where(@conditions)

      @versions.map(&:event).should include('reschedule')
    end
  end

  describe "Rejecting a lead" do
    before do
      @lead = FactoryGirl.create(:lead, :user => current_user, :status => "new")
      @conditions = {:item_id => @lead.id, :item_type => @lead.class.name, :whodunnit => PaperTrail.whodunnit}
    end

    it "should create 'rejected' lead event" do
      @lead.update_attribute(:status, "rejected")
      @versions = Version.where(@conditions)

      @versions.map(&:event).should include('reject')
    end
  end

  describe "Permissions" do
    before do
      @user = FactoryGirl.create(:user)
      Version.delete_all
    end

    it "should not show the create/update versions if the item is private" do
      @item = FactoryGirl.create(:account, :user => current_user, :access => "Private")
      @item.update_attribute(:updated_at,  1.second.ago)

      @versions = Version.where({:item_id => @item.id, :item_type => @item.class.name})
      @versions.map(&:event).sort.should == %w(create update)
      @versions = Version.latest.visible_to(@user)
      @versions.should == []
    end

    it "should not show the destroy version if the item is private" do
      @item = FactoryGirl.create(:account, :user => current_user, :access => "Private")
      @item.destroy

      @versions = Version.where({:item_id => @item.id, :item_type => @item.class.name})
      @versions.map(&:event).sort.should == %w(create destroy)
      @versions = Version.latest.visible_to(@user)
      @versions.should == []
    end

    it "should not show create/update versions if the item was not shared with the user" do
      @item = FactoryGirl.create(:account,
        :user => current_user,
        :access => "Shared",
        :permissions => [ FactoryGirl.build(:permission, :user => current_user, :asset => @item) ]
      )
      @item.update_attribute(:updated_at, 1.second.ago)

      @versions = Version.where({:item_id => @item.id, :item_type => @item.class.name})
      @versions.map(&:event).sort.should == %w(create update)
      @versions = Version.latest.visible_to(@user)
      @versions.should == []
    end

    it "should not show the destroy version if the item was not shared with the user" do
      @item = FactoryGirl.create(:account,
        :user => current_user,
        :access => "Shared",
        :permissions => [ FactoryGirl.build(:permission, :user => current_user, :asset => @item) ]
      )
      @item.destroy

      @versions = Version.where({:item_id => @item.id, :item_type => @item.class.name})
      @versions.map(&:event).sort.should == %w(create destroy)
      @versions = Version.latest.visible_to(@user)
      @versions.should == []
    end

    it "should show create/update versions if the item was shared with the user" do
      @item = FactoryGirl.create(:account,
        :user => current_user,
        :access => "Shared",
        :permissions => [ FactoryGirl.build(:permission, :user => @user, :asset => @item) ]
      )
      @item.update_attribute(:updated_at, 1.second.ago)

      @versions = Version.where({:item_id => @item.id, :item_type => @item.class.name})
      @versions.map(&:event).sort.should == %w(create update)
      @versions = Version.latest.visible_to(@user)
      @versions.map(&:event).sort.should == %w(create update)
    end
  end

  describe "Exportable" do
    before do
    end
    it_should_behave_like("exportable") do
      v1 = FactoryGirl.create(:version, :whodunnit => FactoryGirl.create(:user).id, :item => FactoryGirl.create(:account))
      v2 = FactoryGirl.create(:version, :whodunnit => FactoryGirl.create(:user, :first_name => nil, :last_name => nil).id, :item => FactoryGirl.create(:account))
      let(:exported) { [v1,v2] }
    end
  end
end
