require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  # GET /
  #----------------------------------------------------------------------------
  describe "responding to GET /" do
    before(:each) do
      require_user
    end

    it "should get a list of activities" do
      @activity = Factory(:activity, :subject => Factory(:account, :user => @current_user))
      controller.should_receive(:get_activities).once.and_return([ @activity ])

      get :index
      assigns[:activities].should == [ @activity ]
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
      @asset = Factory(:preference, :user => @current_user, :name => "activity_asset", :value => Base64.encode64(Marshal.dump("tasks")))
      @user = Factory(:preference, :user => @current_user, :name => "activity_user", :value => Base64.encode64(Marshal.dump("Billy Bones")))
      @duration = Factory(:preference, :user => @current_user, :name => "activity_duration", :value => Base64.encode64(Marshal.dump("two days")))

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
      session.keys.should_not include(:hello)
    end

    it "should toggle expand/collapse state of form section in the session (save new session key)" do
      session.delete(:hello)

      xhr :get, :toggle, :id => "hello"
      session[:hello].should == true
    end
  end

end
