require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  # GET /
  #----------------------------------------------------------------------------
  describe "responding to GET /" do
    before(:each) do
      require_user
    end

    context "list of activities" do
      it "should get a list of activities" do
        @activity = Factory(:activity, :subject => Factory(:account, :user => @current_user))
        controller.should_receive(:get_activities).once.and_return([ @activity ])
  
        get :index
        assigns[:activities].should == [ @activity ]
      end
      it "should limit the list to 5" do
        10.times do
          Factory(:activity, :subject => Factory(:account, :user => @current_user))
        end
        get :index
        assigns[:activities].count.should == 5
      end
    end

    it "should get a list of my tasks ordered by due_at" do
      
      #tasks assigned to the current user
      task_1 = Factory(:task, :name => "Your first task", :bucket => "due_asap", :assigned_to => @current_user.id)
      task_2 = Factory.build(:task, :name => "Another task for you", :bucket => "specific_time", :assigned_to => @current_user.id)
      task_2.calendar = 5.days.from_now.to_s
      task_2.save
      task_3 = Factory(:task, :name => "Third Task", :bucket => "due_next_week", :assigned_to => @current_user.id)
      
      
      task_4 = Factory.build(:task, :name => "i've assigned it to myself", :user => @current_user, :assigned_to => nil, :bucket => "specific_time")
      task_4.calendar = 20.days.from_now.to_s
      task_4.save
      Factory(:task, :name => "Someone else's Task", :user_id => @current_user.id, :bucket => "due_asap", :assigned_to => Factory(:user).id)
      Factory(:task, :name => "Not my task", :bucket => "due_asap", :assigned_to => Factory(:user).id)
      
      get :index
      assigns[:my_tasks].should == [task_1, task_2, task_3]
    end
    it "should get a list of my opportunities ordered by closes_on" do
      
      #tasks assigned to the current user
      opportunity_1 = Factory(:opportunity, :name => "Your first opportunity", :closes_on => 15.days.from_now, :assigned_to => @current_user.id)      
      opportunity_2 = Factory(:opportunity, :name => "Another opportunity for you", :closes_on => 10.days.from_now, :assigned_to => @current_user.id)
      opportunity_3 = Factory(:opportunity, :name => "Third Opportunity", :closes_on => 5.days.from_now, :assigned_to => @current_user.id)
      
      opportunity_4 = Factory(:opportunity, :name => "Fourth Opportunity", :closes_on => 50.days.from_now, :assigned_to => nil, :user_id => @current_user.id)
      Factory(:opportunity, :name => "Someone else's Opportunity", :assigned_to => Factory(:user).id)
      Factory(:opportunity, :name => "Not my opportunity", :assigned_to => Factory(:user).id)

      get :index
      assigns[:my_opportunities].should == [opportunity_3, opportunity_2, opportunity_1]
    end
    it "should get a list of my accounts ordered by name" do
      
      #tasks assigned to the current user
      account_1 = Factory(:account, :name => "Anderson", :assigned_to => @current_user.id)
      account_2 = Factory(:account, :name => "Wilson", :assigned_to => @current_user.id)
      account_3 = Factory(:account, :name => "Triple", :assigned_to => @current_user.id)
      
      account_4 = Factory(:account, :name => "Double", :assigned_to => nil, :user_id => @current_user.id)
      Factory(:account, :name => "Someone else's Account", :assigned_to => Factory(:user).id)
      Factory(:account, :name => "Not my account", :assigned_to => Factory(:user).id)

      get :index
      assigns[:my_accounts].should == [account_1, account_3, account_2]
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
  describe "responding to GET toggle" do
    before(:each) do
      require_user
    end

    it "should assign instance variables for user preferences" do
      @asset = Factory(:preference, :user => @current_user, :name => "activity_asset", :value => Base64.encode64(Marshal.dump("tasks")))
      @user = Factory(:preference, :user => @current_user, :name => "activity_user", :value => Base64.encode64(Marshal.dump("Billy Bones")))
      @duration = Factory(:preference, :user => @current_user, :name => "activity_duration", :value => Base64.encode64(Marshal.dump("two days")))

      xhr :get, :options
      assigns[:asset].should == "tasks"
      assigns[:user].should == "Billy Bones"
      assigns[:duration].should == "two days"
    end

    it "should not assign instance variables when hiding options" do
      xhr :get, :options, :cancel => "true"
      assigns[:asset].should == nil
      assigns[:user].should == nil
      assigns[:duration].should == nil
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
      @activity = Factory(:activity, :subject => Factory(:account, :user => @current_user))
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
      session.data.keys.should_not include(:hello)
    end

    it "should toggle expand/collapse state of form section in the session (save new session key)" do
      session.delete(:hello)

      xhr :get, :toggle, :id => "hello"
      session[:hello].should == true
    end
  end

end
