# == Schema Information
# Schema version: 23
#
# Table name: activities
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)
#  subject_id   :integer(4)
#  subject_type :string(255)
#  action       :string(32)      default("created")
#  info         :string(255)     default("")
#  private      :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Activity do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Activity.create!(:user => Factory(:user), :subject => Factory(:lead))
  end

  describe "with multiple activity records" do

    before(:each) do
      @user = Factory(:user)
      @actions = %w(created deleted updated viewed).freeze
      @actions.each_with_index do |action, index|
        Factory(:activity, :action => action, :user => @user, :subject => Factory(:lead))
        Factory(:activity, :action => action, :subject => Factory(:lead)) # different user
      end
    end

    it "should select all activities except one" do
      @activities = Activity.for(@user).except(:viewed)
      @activities.map(&:action).sort.should == %w(created deleted updated)
    end

    it "should select all activities except many" do
      @activities = Activity.for(@user).except(:created, :updated, :deleted)
      @activities.map(&:action).should == %w(viewed)
    end

    it "should select one requested activity" do
      @activities = Activity.for(@user).only(:deleted)
      @activities.map(&:action).should == %w(deleted)
    end

    it "should select many requested activities" do
      @activities = Activity.for(@user).only(:created, :updated)
      @activities.map(&:action).sort.should == %w(created updated)
    end

    it "should select activities for given user" do
      @activities = Activity.for(@user)
      @activities.map(&:action).sort.should == @actions
    end

  end

  %w(account campaign contact lead opportunity task).each do |subject|
    describe "Create, update, and delete (#{subject})" do
      before(:each) do
        @subject = Factory(subject.to_sym, :user => @current_user)
        @conditions = [ "user_id=? AND subject_id=? AND subject_type=? AND action=?", @current_user.id, @subject.id, subject.capitalize ]
      end

      it "should add an activity when creating new #{subject}" do
        @activity = Activity.first(:conditions => (@conditions << "created"))
        @activity.should_not == nil
        @activity.info.should == (@subject.respond_to?(:full_name) ? @subject.full_name : @subject.name)
      end

      it "should add an activity when updating existing #{subject}" do
        if @subject.respond_to?(:full_name)
          @subject.update_attributes(:first_name => "Billy", :last_name => "Bones")
        else
          @subject.update_attributes(:name => "Billy Bones")
        end
        @activity = Activity.first(:conditions => (@conditions << "updated"))

        @activity.should_not == nil
        @activity.info.should == "Billy Bones"
      end

      it "should add an activity when deleting #{subject}" do
        @subject.destroy
        @activity = Activity.first(:conditions => (@conditions << "deleted"))

        @activity.should_not == nil
        @activity.info.should == (@subject.respond_to?(:full_name) ? @subject.full_name : @subject.name)
      end

      it "should add an activity when commenting on a #{subject}" do
        @comment = Factory(:comment, :commentable => @subject)

        @activity = Activity.first(:conditions => (@conditions << "commented"))
        @activity.should_not == nil
        @activity.info.should == (@subject.respond_to?(:full_name) ? @subject.full_name : @subject.name)
      end

      describe "on a record marked as deleted" do
        it "should still be able to update" do
          @subject.destroy
          deleted = subject.classify.constantize.find_with_deleted(@subject)

          if deleted.respond_to?(:full_name)
            deleted.update_attributes(:first_name => "Billy", :last_name => "Bones DELETED")
          else
            deleted.update_attributes(:name => "Billy Bones DELETED")
          end
          @activity = Activity.first(:conditions => (@conditions << "updated"))

          @activity.should_not == nil
          @activity.info.should == "Billy Bones DELETED"
        end
      end

      describe "on an actually deleted record" do
        it "should wipe out all associated activity records" do
          @subject.destroy!
          @activities = Activity.all(:conditions => [ "user_id=? AND subject_id=? AND subject_type=?", @current_user.id, @subject.id, subject.capitalize ])

          lambda { subject.classify.constantize.find_with_deleted(@subject) }.should raise_error(ActiveRecord::RecordNotFound)
          @activities.should == []
        end
      end
    end

  end

  %w(account campaign contact lead opportunity).each do |subject|
    describe "Recently viewed items (#{subject})" do
      before(:each) do
        @subject = Factory(subject.to_sym, :user => @current_user)
        @conditions = [ "user_id=? AND subject_id=? AND subject_type=? AND action='viewed'", @current_user.id, @subject.id, subject.capitalize ]
      end

      it "creating a new #{subject} should also make it a recently viewed item" do
        @activity = Activity.first(:conditions => @conditions)

        @activity.should_not == nil
      end

      it "updating #{subject} should also mark it as recently viewed" do
        @before = Activity.first(:conditions => @conditions)
        if @subject.respond_to?(:full_name)
          @subject.update_attributes(:first_name => "Billy", :last_name => "Bones")
        else
          @subject.update_attributes(:name => "Billy Bones")
        end
        @after = Activity.first(:conditions => @conditions)

        @before.should_not == nil
        @after.should_not == nil
        @after.updated_at.should >= @before.updated_at
      end

      it "deleting #{subject} should remove it from recently viewed items" do
        @subject.destroy
        @activity = Activity.first(:conditions => @conditions)

        @activity.should be_nil
      end

      it "deleting #{subject} should remove it from recently viewed items for all other users" do
        @somebody = Factory(:user)
        @subject = Factory(subject.to_sym, :user => @somebody,  :access => "Public")
        Factory(:activity, :user => @somebody, :subject => @subject, :action => "viewed")

        @activity = Activity.first(:conditions => [ "user_id=? AND subject_id=? AND subject_type=? AND action='viewed'", @somebody.id, @subject.id, subject.capitalize ])
        @activity.should_not == nil

        # Now @current_user destroys somebody's object: somebody should no longer have it :viewed.
        @subject.destroy
        @activity = Activity.first(:conditions => [ "user_id=? AND subject_id=? AND subject_type=? AND action='viewed'", @somebody.id, @subject.id, subject.capitalize ])
        @activity.should be_nil
      end
    end
  end

  describe "Recently viewed items (task)" do
    before(:each) do
      @task = Factory(:task)
      @conditions = [ "subject_id=? AND subject_type='Task'", @task.id ]
    end

    it "creating a new task should not add it to recently viewed items list" do
      @activities = Activity.all(:conditions => @conditions)

      @activities.map(&:action).should == %w(created) # but not viewed
    end

    it "updating a new task should not add it to recently viewed items list" do
      @task.update_attribute(:updated_at, 1.second.ago)
      @activities = Activity.all(:conditions => @conditions)

      @activities.map(&:action).sort.should == %w(created updated) # but not viewed
    end
  end

  describe "Action refinements for task updates" do
    before(:each) do
      @task = Factory(:task, :user => @current_user)
      @conditions = [ "subject_id=? AND subject_type='Task' AND user_id=?", @task.id, @current_user ]
    end

    it "should create 'completed' task action" do
      @task.update_attribute(:completed_at, 1.second.ago)
      @activities = Activity.all(:conditions => @conditions)

      @activities.map(&:action).sort.should == %w(completed created)
    end

    it "should create 'reassigned' task action" do
      @task.update_attribute(:assigned_to, @current_user.id + 1)
      @activities = Activity.all(:conditions => @conditions)

      @activities.map(&:action).sort.should == %w(created reassigned)
    end

    it "should create 'rescheduled' task action" do
      @task.update_attribute(:bucket, "due_tomorrow") # Factory creates :due_asap task
      @activities = Activity.all(:conditions => @conditions)

      @activities.map(&:action).sort.should == %w(created rescheduled)
    end
  end

  describe "Rejecting a lead" do
    before(:each) do
      @lead = Factory(:lead, :user => @current_user, :status => "new")
      @conditions = [ "subject_id=? AND subject_type='Lead' AND user_id=?", @lead.id, @current_user ]
    end

    it "should create 'rejected' lead action" do
      @lead.update_attribute(:status, "rejected")
      @activities = Activity.all(:conditions => @conditions)

      @activities.map(&:action).sort.should == %w(created rejected viewed)
    end

    it "should not mark it as recently viewed" do
      Activity.delete_all                                   # delete :created and :viewed
      @lead.update_attribute(:status, "rejected")
      @activities = Activity.all(:conditions => @conditions)

      @activities.map(&:action).sort.should == %w(rejected) # no :viewed, only :rejected
    end

  end

  describe "Permissions" do
    it "should not show the created/updated activities if the subject is private" do
      @subject = Factory(:account, :user => Factory(:user), :access => "Private")
      @subject.update_attribute(:updated_at,  1.second.ago)

      @activities = Activity.all(:conditions => [ "subject_id=? AND subject_type=?", @subject.id, subject.class.name.capitalize ]);
      @activities.map(&:action).sort.should == %w(created updated viewed)
      @activities = Activity.latest({}).visible_to(@current_user)
      @activities.should == []
    end

    it "should not show the deleted activity if the subject is private" do
      @subject = Factory(:account, :user => Factory(:user), :access => "Private")
      @subject.destroy

      @activities = Activity.all(:conditions => [ "subject_id=? AND subject_type=?", @subject.id, subject.class.name.capitalize ]);
      @activities.map(&:action).sort.should == %w(created deleted)
      @activities = Activity.latest({}).visible_to(@current_user)
      @activities.should == []
    end

    it "should not show created/updated activities if the subject was not shared with the user" do
      @user = Factory(:user)
      @subject = Factory(:account,
        :user => @user,
        :access => "Shared",
        :permissions => [ Factory.build(:permission, :user => @user, :asset => @subject) ]
      )
      @subject.update_attribute(:updated_at, 1.second.ago)

      @activities = Activity.all(:conditions => [ "subject_id=? AND subject_type=?", @subject.id, subject.class.name.capitalize ]);
      @activities.map(&:action).sort.should == %w(created updated viewed)
      @activities = Activity.latest({}).visible_to(@current_user)
      @activities.should == []
    end

    it "should not show the deleted activity if the subject was not shared with the user" do
      @user = Factory(:user)
      @subject = Factory(:account,
        :user => @user,
        :access => "Shared",
        :permissions => [ Factory.build(:permission, :user => @user, :asset => @subject) ]
      )
      @subject.destroy

      @activities = Activity.all(:conditions => [ "subject_id=? AND subject_type=?", @subject.id, subject.class.name.capitalize ]);
      @activities.map(&:action).sort.should == %w(created deleted)
      @activities = Activity.latest({}).visible_to(@current_user)
      @activities.should == []
    end

    it "should show created/updated activities if the subject was shared with the user" do
      @subject = Factory(:account,
        :user => Factory(:user),
        :access => "Shared",
        :permissions => [ Factory.build(:permission, :user => @current_user, :asset => @subject) ]
      )
      @subject.update_attribute(:updated_at, 1.second.ago)

      @activities = Activity.all(:conditions => [ "subject_id=? AND subject_type=?", @subject.id, subject.class.name.capitalize ]);
      @activities.map(&:action).sort.should == %w(created updated viewed)

      @activities = Activity.latest({}).visible_to(@current_user)
      @activities.map(&:action).sort.should == %w(created updated viewed)
    end

    it "should show deleted activity if the subject was shared with the user" do
      @subject = Factory(:account,
        :user => Factory(:user),
        :access => "Shared",
        :permissions => [ Factory.build(:permission, :user => @current_user, :asset => @subject) ]
      )
      @subject.destroy

      @activities = Activity.latest({}).visible_to(@current_user)
      @activities.map(&:action).sort.should == %w(created deleted)
    end
  end

end
