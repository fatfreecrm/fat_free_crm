require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  # GET /
  #----------------------------------------------------------------------------
  describe "responding to GET /" do
    before(:each) do
      require_user
    end

    it "should get a list of activities" do
      @activity = FactoryGirl.create(:version, :item => FactoryGirl.create(:account, :user => @current_user))
      controller.should_receive(:get_activities).once.and_return([ @activity ])

      get :index
      assigns[:activities].should == [ @activity ]
    end

    it "should get a list of my tasks ordered by due_at" do
      task_1 = FactoryGirl.create(:task, :name => "Your first task", :bucket => "due_asap", :assigned_to => @current_user.id)
      task_2 = FactoryGirl.create(:task, :name => "Another task for you", :bucket => "specific_time", :calendar => 5.days.from_now.strftime("%m/%d/%Y %I:%M %p"), :assigned_to => @current_user.id)
      task_3 = FactoryGirl.create(:task, :name => "Third Task", :bucket => "due_next_week", :assigned_to => @current_user.id)
      task_4 = FactoryGirl.create(:task, :name => "i've assigned it to myself", :user => @current_user, :calendar => 20.days.from_now.strftime("%m/%d/%Y %I:%M %p"), :assigned_to => nil, :bucket => "specific_time")

      FactoryGirl.create(:task, :name => "Someone else's Task", :user_id => @current_user.id, :bucket => "due_asap", :assigned_to => FactoryGirl.create(:user).id)
      FactoryGirl.create(:task, :name => "Not my task", :bucket => "due_asap", :assigned_to => FactoryGirl.create(:user).id)

      get :index
      assigns[:my_tasks].should == [task_1, task_2, task_3, task_4]
    end

    it "should get a list of my opportunities ordered by closes_on" do
      opportunity_1 = FactoryGirl.create(:opportunity, :name => "Your first opportunity", :closes_on => 15.days.from_now, :assigned_to => @current_user.id)
      opportunity_2 = FactoryGirl.create(:opportunity, :name => "Another opportunity for you", :closes_on => 10.days.from_now, :assigned_to => @current_user.id)
      opportunity_3 = FactoryGirl.create(:opportunity, :name => "Third Opportunity", :closes_on => 5.days.from_now, :assigned_to => @current_user.id)
      opportunity_4 = FactoryGirl.create(:opportunity, :name => "Fourth Opportunity", :closes_on => 50.days.from_now, :assigned_to => nil, :user_id => @current_user.id)

      FactoryGirl.create(:opportunity, :name => "Someone else's Opportunity", :assigned_to => FactoryGirl.create(:user).id)
      FactoryGirl.create(:opportunity, :name => "Not my opportunity", :assigned_to => FactoryGirl.create(:user).id)

      get :index
      assigns[:my_opportunities].should == [opportunity_3, opportunity_2, opportunity_1, opportunity_4]
    end

    it "should get a list of my accounts ordered by name" do
      account_1 = FactoryGirl.create(:account, :name => "Anderson", :assigned_to => @current_user.id)
      account_2 = FactoryGirl.create(:account, :name => "Wilson", :assigned_to => @current_user.id)
      account_3 = FactoryGirl.create(:account, :name => "Triple", :assigned_to => @current_user.id)
      account_4 = FactoryGirl.create(:account, :name => "Double", :assigned_to => nil, :user_id => @current_user.id)

      FactoryGirl.create(:account, :name => "Someone else's Account", :assigned_to => FactoryGirl.create(:user).id)
      FactoryGirl.create(:account, :name => "Not my account", :assigned_to => FactoryGirl.create(:user).id)

      get :index
      assigns[:my_accounts].should == [account_1, account_4, account_3, account_2]
    end

    it "should assign @hello and call hook" do
      require_user
      controller.should_receive(:hook).at_least(:once)

      get :index
      assigns[:hello].should == "Hello world"
    end
  end

  # GET /home/options                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET options" do
    before(:each) do
      require_user
    end

    it "should assign instance variables for user preferences" do
      @asset = FactoryGirl.create(:preference, :user => @current_user, :name => "activity_asset", :value => Base64.encode64(Marshal.dump("tasks")))
      @user = FactoryGirl.create(:preference, :user => @current_user, :name => "activity_user", :value => Base64.encode64(Marshal.dump("Billy Bones")))
      @duration = FactoryGirl.create(:preference, :user => @current_user, :name => "activity_duration", :value => Base64.encode64(Marshal.dump("two days")))

      xhr :get, :options
      assigns[:asset].should == "tasks"
      assigns[:user].should == "Billy Bones"
      assigns[:duration].should == "two days"
      assigns[:all_users].should == User.order("first_name, last_name").all
    end

    it "should not assign instance variables when hiding options" do
      xhr :get, :options, :cancel => "true"
      assigns[:asset].should == nil
      assigns[:user].should == nil
      assigns[:duration].should == nil
      assigns[:all_users].should == nil
    end
  end

  # POST /home/redraw                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST redraw" do
    before(:each) do
      require_user
    end

    it "should save user selected options" do
      xhr :post, :redraw, :asset => "tasks", :user => "Billy Bones", :duration => "two days"
      @current_user.pref[:activity_asset].should == "tasks"
      @current_user.pref[:activity_user].should == "Billy Bones"
      @current_user.pref[:activity_duration].should == "two days"
    end

    it "should get a list of activities" do
      @activity = FactoryGirl.create(:version, :item => FactoryGirl.create(:account, :user => @current_user))
      controller.should_receive(:get_activities).once.and_return([ @activity ])

      get :index
      assigns[:activities].should == [ @activity ]
    end
  end

  # GET /home/toggle                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET toggle" do
    it "should toggle expand/collapse state of form section in the session (delete existing session key)" do
      session[:hello] = "world"

      xhr :get, :toggle, :id => "hello"
      session.keys.should_not include(:hello)
    end

    it "should toggle expand/collapse state of form section in the session (save new session key)" do
      session.delete(:hello)

      xhr :get, :toggle, :id => "hello"
      session[:hello].should == true
    end
  end
  
  describe "activity_user" do
  
    before(:each) do
      @user = mock(User, :id => 1, :is_a? => true)
      @cur_user = mock(User)
    end
  
    it "should find a user by email" do
      @cur_user.stub!(:pref).and_return(:activity_user => 'billy@example.com')
      controller.instance_variable_set(:@current_user, @cur_user)
      User.should_receive(:where).with(:email => 'billy@example.com').and_return([@user])
      controller.send(:activity_user).should == 1
    end
    
    it "should find a user by first name or last name" do
      @cur_user.stub!(:pref).and_return(:activity_user => 'Billy')
      controller.instance_variable_set(:@current_user, @cur_user)
      User.should_receive(:where).with("upper(first_name) LIKE upper('%Billy%') OR upper(last_name) LIKE upper('%Billy%')").and_return([@user])
      controller.send(:activity_user).should == 1
    end
    
    it "should find a user by first name and last name" do
      @cur_user.stub!(:pref).and_return(:activity_user => 'Billy Elliot')
      controller.instance_variable_set(:@current_user, @cur_user)
      User.should_receive(:where).with("(upper(first_name) LIKE upper('%Billy%') AND upper(last_name) LIKE upper('%Elliot%')) OR (upper(first_name) LIKE upper('%Elliot%') AND upper(last_name) LIKE upper('%Billy%'))").and_return([@user])
      controller.send(:activity_user).should == 1
    end
    
    it "should return nil when 'all_users' is specified" do
      @cur_user.stub!(:pref).and_return(:activity_user => 'all_users')
      controller.instance_variable_set(:@current_user, @cur_user)
      User.should_not_receive(:where)
      controller.send(:activity_user).should == nil
    end
    
  end

end
