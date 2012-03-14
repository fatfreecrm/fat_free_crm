# == Schema Information
#
# Table name: versions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  item_id   :integer
#  item_type :string(255)
#  event       :string(32)      default("created")
#  info         :string(255)     default("")
#  private      :boolean         default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Version do

  before { login }

  it "should create a new instance given valid attributes" do
    Version.create!(:user => FactoryGirl.create(:user), :item => FactoryGirl.create(:lead))
  end

  describe "with multiple version records" do
    before do
      @user = FactoryGirl.create(:user)
      @events = %w(created deleted updated viewed).freeze
      @events.each_with_index do |event, index|
        FactoryGirl.create(:version, :event => event, :user => @user, :item => FactoryGirl.create(:lead))
        FactoryGirl.create(:version, :event => event, :item => FactoryGirl.create(:lead)) # different user
      end
    end

    it "should select all versions except one" do
      @versions = Version.for(@user).without_events(:viewed)
      @versions.map(&:event).sort.should == %w(created deleted updated)
    end

    it "should select all versions except many" do
      @versions = Version.for(@user).without_events(:created, :updated, :deleted)
      @versions.map(&:event).should == %w(viewed)
    end

    it "should select one requested version" do
      @versions = Version.for(@user).with_events(:deleted)
      @versions.map(&:event).should == %w(deleted)
    end

    it "should select many requested versions" do
      @versions = Version.for(@user).with_events(:created, :updated)
      @versions.map(&:event).sort.should == %w(created updated)
    end

    it "should select versions for given user" do
      @versions = Version.for(@user)
      @versions.map(&:event).sort.should == @events
    end
  end

  %w(account campaign contact lead opportunity task).each do |item|
    describe "Create, update, and delete (#{item})" do
      before :each do
        @item = FactoryGirl.create(item.to_sym, :user => @current_user)
        @conditions = [ 'user_id = ? AND item_id = ? AND item_type = ? AND event = ?', @current_user.id, @item.id, @item.class.name ]
      end

      it "should add an version when creating new #{item}" do
        @version = Version.where(@conditions << 'created').first
        @version.should_not == nil
        @version.info.should == (@item.respond_to?(:full_name) ? @item.full_name : @item.name)
      end

      it "should add an version when updating existing #{item}" do
        if @item.respond_to?(:full_name)
          @item.update_attributes(:first_name => "Billy", :last_name => "Bones")
        else
          @item.update_attributes(:name => "Billy Bones")
        end
        @version = Version.where(@conditions << 'updated').first

        @version.should_not == nil
        @version.info.ends_with?("Billy Bones").should == true
      end

      it "should add an version when deleting #{item}" do
        @item.destroy
        @version = Version.where(@conditions << 'deleted').first

        @version.should_not == nil
        @version.info.should == (@item.respond_to?(:full_name) ? @item.full_name : @item.name)
      end

      it "should add an version when commenting on a #{item}" do
        @comment = FactoryGirl.create(:comment, :commentable => @item, :user => @current_user)

        @version = Version.where(@conditions << 'commented').first
        @version.should_not == nil
        @version.info.should == (@item.respond_to?(:full_name) ? @item.full_name : @item.name)
      end
    end
  end

  %w(account campaign contact lead opportunity).each do |item|
    describe "Recently viewed items (#{item})" do
      before do
        @item = FactoryGirl.create(item.to_sym, :user => @current_user)
        @conditions = [ "user_id = ? AND item_id = ? AND item_type = ? AND event = 'viewed'", @current_user.id, @item.id, @item.class.name ]
      end

      it "creating a new #{item} should also make it a recently viewed item" do
        @version = Version.where(@conditions).first

        @version.should_not == nil
      end

      it "updating #{item} should also mark it as recently viewed" do
        @before = Version.where(@conditions).first
        if @item.respond_to?(:full_name)
          @item.update_attributes(:first_name => "Billy", :last_name => "Bones")
        else
          @item.update_attributes(:name => "Billy Bones")
        end
        @after = Version.where(@conditions).first

        @before.should_not == nil
        @after.should_not == nil
        @after.updated_at.should >= @before.updated_at
      end

      it "deleting #{item} should remove it from recently viewed items" do
        @item.destroy
        @version = Version.where(@conditions).first

        @version.should be_nil
      end

      it "deleting #{item} should remove it from recently viewed items for all other users" do
        @somebody = FactoryGirl.create(:user)
        @item = FactoryGirl.create(item.to_sym, :user => @somebody,  :access => "Public")
        FactoryGirl.create(:version, :user => @somebody, :item => @item, :event => "viewed")

        @version = Version.where("user_id = ? AND item_id = ? AND item_type = ? AND event = 'viewed'", @somebody.id, @item.id, @item.class.name).first
        @version.should_not == nil

        # Now @current_user destroys somebody's object: somebody should no longer have it :viewed.
        @item.destroy
        @version = Version.where("user_id = ? AND item_id = ? AND item_type = ? AND event = 'viewed'", @somebody.id, @item.id, @item.class.name).first
        @version.should be_nil
      end
    end
  end

  describe "Recently viewed items (task)" do
    before do
      @task = FactoryGirl.create(:task)
      @conditions = [ "item_id = ? AND item_type = 'Task'", @task.id ]
    end

    it "creating a new task should not add it to recently viewed items list" do
      @versions = Version.where(@conditions)

      @versions.map(&:event).should == %w(created) # but not viewed
    end

    it "updating a new task should not add it to recently viewed items list" do
      @task.update_attribute(:updated_at, 1.second.ago)
      @versions = Version.where(@conditions)

      @versions.map(&:event).sort.should == %w(created updated) # but not viewed
    end
  end

  describe "Action refinements for task updates" do
    before do
      @task = FactoryGirl.create(:task, :user => @current_user)
      @conditions = [ "item_id=? AND item_type='Task' AND user_id=?", @task.id, @current_user ]
    end

    it "should create 'completed' task event" do
      @task.update_attribute(:completed_at, 1.second.ago)
      @versions = Version.where(@conditions)

      @versions.map(&:event).sort.should == %w(completed created)
    end

    it "should create 'reassigned' task event" do
      @task.update_attribute(:assigned_to, @current_user.id + 1)
      @versions = Version.where(@conditions)

      @versions.map(&:event).sort.should == %w(created reassigned)
    end

    it "should create 'rescheduled' task event" do
      @task.update_attribute(:bucket, "due_tomorrow") # FactoryGirl creates :due_asap task
      @versions = Version.where(@conditions)

      @versions.map(&:event).sort.should == %w(created rescheduled)
    end
  end

  describe "Rejecting a lead" do
    before do
      @lead = FactoryGirl.create(:lead, :user => @current_user, :status => "new")
      @conditions = [ "item_id = ? AND item_type = 'Lead' AND user_id = ?", @lead.id, @current_user ]
    end

    it "should create 'rejected' lead event" do
      @lead.update_attribute(:status, "rejected")
      @versions = Version.where(@conditions)

      @versions.map(&:event).sort.should == %w(created rejected viewed)
    end

    it "should not mark it as recently viewed" do
      Version.delete_all                                   # delete :created and :viewed
      @lead.update_attribute(:status, "rejected")
      @versions = Version.where(@conditions)

      @versions.map(&:event).sort.should == %w(rejected) # no :viewed, only :rejected
    end
  end

  describe "Permissions" do
    it "should not show the created/updated versions if the item is private" do
      @item = FactoryGirl.create(:account, :user => FactoryGirl.create(:user), :access => "Private")
      @item.update_attribute(:updated_at,  1.second.ago)

      @versions = Version.where('item_id = ? AND item_type = ?', @item.id, @item.class.name)
      @versions.map(&:event).sort.should == %w(created updated viewed)
      @versions = Version.latest({}).visible_to(@current_user)
      @versions.should == []
    end

    it "should not show the deleted version if the item is private" do
      @item = FactoryGirl.create(:account, :user => FactoryGirl.create(:user), :access => "Private")
      @item.destroy

      @versions = Version.where('item_id = ? AND item_type = ?', @item.id, @item.class.name)
      @versions.map(&:event).sort.should == %w(created deleted)
      @versions = Version.latest({}).visible_to(@current_user)
      @versions.should == []
    end

    it "should not show created/updated versions if the item was not shared with the user" do
      @user = FactoryGirl.create(:user)
      @item = FactoryGirl.create(:account,
        :user => @user,
        :access => "Shared",
        :permissions => [ FactoryGirl.build(:permission, :user => @user, :asset => @item) ]
      )
      @item.update_attribute(:updated_at, 1.second.ago)

      @versions = Version.where('item_id = ? AND item_type = ?', @item.id, @item.class.name)
      @versions.map(&:event).sort.should == %w(created updated viewed)
      @versions = Version.latest({}).visible_to(@current_user)
      @versions.should == []
    end

    it "should not show the deleted version if the item was not shared with the user" do
      @user = FactoryGirl.create(:user)
      @item = FactoryGirl.create(:account,
        :user => @user,
        :access => "Shared",
        :permissions => [ FactoryGirl.build(:permission, :user => @user, :asset => @item) ]
      )
      @item.destroy

      @versions = Version.where('item_id = ? AND item_type = ?', @item.id, @item.class.name)
      @versions.map(&:event).sort.should == %w(created deleted)
      @versions = Version.latest({}).visible_to(@current_user)
      @versions.should == []
    end

    it "should show created/updated versions if the item was shared with the user" do
      @item = FactoryGirl.create(:account,
        :user => FactoryGirl.create(:user),
        :access => "Shared",
        :permissions => [ FactoryGirl.build(:permission, :user => @current_user, :asset => @item) ]
      )
      @item.update_attribute(:updated_at, 1.second.ago)

      @versions = Version.where('item_id = ? AND item_type = ?', @item.id, @item.class.name)
      @versions.map(&:event).sort.should == %w(created updated viewed)

      @versions = Version.latest({}).visible_to(@current_user)
      @versions.map(&:event).sort.should == %w(created updated viewed)
    end
  end

  describe "Exportable" do
    before do
      Version.delete_all
      FactoryGirl.create(:version, :user => FactoryGirl.create(:user), :item => FactoryGirl.create(:account))
      FactoryGirl.create(:version, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :item => FactoryGirl.create(:account))
      Version.delete_all("event IS NOT NULL") # Delete created and views events that are created implicitly.
    end
    it_should_behave_like("exportable") do
      let(:exported) { Version.all }
    end
  end
end
