require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do

  def update_sidebar
    @task_total = { :key => :value, :pairs => :etc }
    Task.stub!(:totals).and_return(@task_total)
  end

  def produce_tasks(user, view)
    settings = (view != "completed" ? Setting.as_hash(:task_bucket) : Setting.as_hash(:task_completed))

    settings.keys.inject({}) do | hash, due |
      hash[due] ||= []
      if Date.tomorrow == Date.today.end_of_week && due == :due_tomorrow
        due = :due_this_week
        hash[due] ||= []
      end
      hash[due] << case view
      when "pending"
        Factory(:task, :user => user, :bucket => due.to_s)
      when "assigned"
        Factory(:task, :user => user, :bucket => due.to_s, :assigned_to => 1)
      when "completed"
        completed_at = case due
          when :completed_today
            Date.today
          when :completed_yesterday
            Date.yesterday
          when :completed_last_week
            Date.today.beginning_of_week - 7.days
          when :completed_this_month
            Date.today.beginning_of_month
          when :completed_last_month
            Date.today.beginning_of_month - 1.day
        end
        Factory(:task, :user => user, :bucket => due.to_s, :completed_at => completed_at)
      end
      hash
    end
  end

  before(:each) do
    require_user
    set_current_tab(:tasks)
  end

  # GET /tasks
  # GET /tasks.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do

    before(:each) do
      update_sidebar
    end

    VIEWS.each do |view|
      it "should expose all tasks as @tasks and render [index] template for #{view} view" do
        @tasks = produce_tasks(@current_user, view)

        get :index, :view => view

        (assigns[:tasks].keys - @tasks.keys).should == []
        (assigns[:tasks].values.flatten - @tasks.values.flatten).should == []
        assigns[:task_total].should == @task_total
        response.should render_template("tasks/index")
      end

      # it "should render all tasks as xml for #{view} view" do
      #   @tasks = produce_tasks(@current_user, view)
      # 
      #   # Convert symbol keys to strings, otherwise to_xml fails (Rails 2.2).
      #   @tasks = @tasks.inject({}) { |tasks, (k,v)| tasks[k.to_s] = v; tasks }
      # 
      #   request.env["HTTP_ACCEPT"] = "application/xml"
      #   get :index, :view => view
      #   (assigns[:tasks].keys.map(&:to_s) - @tasks.keys).should == []
      #   (assigns[:tasks].values.flatten - @tasks.values.flatten).should == []
      #   response.body.should == @tasks.to_xml unless Date.tomorrow == Date.today.end_of_week # Cheating...
      # end
    end

  end

  # GET /tasks/1
  # GET /tasks/1.xml
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    VIEWS.each do |view|
      it "should render tasks index for #{view}  view (since a task doesn't have landing page)" do
        get :show, :id => 42, :view => view
        response.should render_template("tasks/index")
      end

      it "should render the requested task as xml for #{view} view" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @task = Factory(:task, :id => 42)

        get :show, :id => 42, :view => "pending"
        response.body.should == @task.to_xml
      end
    end

  end

  # GET /tasks/new
  # GET /tasks/new.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    it "should expose a new task as @task and render [new] template" do
      account = Factory(:account, :user => @current_user)
      @task = Factory.build(:task, :user => @current_user, :asset => account)
      Task.stub!(:new).and_return(@task)
      @users = [ Factory(:user) ]
      @bucket = Setting.task_bucket[1..-1] << [ "On Specific Date...", :specific_time ]
      @category = Setting.invert(:task_category)

      xhr :get, :new
      assigns[:task].should == @task
      assigns[:users].should == @users
      assigns[:bucket].should == @bucket
      assigns[:category].should == @category
      response.should render_template("tasks/new")
    end

    it "should find related asset when necessary" do
      @asset = Factory(:account, :id => 42)

      xhr :get, :new, :related => "account_42"
      assigns[:asset].should == @asset
      response.should render_template("tasks/new")
    end

  end

  # GET /tasks/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    it "should expose the requested task as @task and render [edit] template" do
      @asset = Factory(:account, :user => @current_user)
      @task = Factory(:task, :id => 42, :user => @current_user, :asset => @asset)
      @users = [ Factory(:user) ]
      @bucket = Setting.task_bucket[1..-1] << [ "On Specific Date...", :specific_time ]
      @category = Setting.invert(:task_category)

      xhr :get, :edit, :id => 42
      assigns[:task].should == @task
      assigns[:users].should == @users
      assigns[:bucket].should == @bucket
      assigns[:category].should == @category
      assigns[:asset].should == @asset
      response.should render_template("tasks/edit")
    end

    it "should find previously open task when necessary" do
      @task = Factory(:task, :id => 42, :user => @current_user)
      @previous = Factory(:task, :id => 999, :user => @current_user)

      xhr :get, :edit, :id => 42, :previous => 999
      assigns[:task].should == @task
      assigns[:previous].should == @previous
      response.should render_template("tasks/edit")
    end

  end

  # POST /tasks
  # POST /tasks.xml                                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created task as @task and render [create] template" do
        @task = Factory.build(:task, :user => @current_user)
        Task.stub!(:new).and_return(@task)

        xhr :post, :create, :task => { :name => "Hello world" }
        assigns(:task).should == @task
        assigns(:view).should == "pending"
        assigns[:task_total].should == nil
        response.should render_template("tasks/create")
      end

      [ "", "?view=pending", "?view=assigned", "?view=completed" ].each do |view|
        it "should update tasks sidebar when [create] is being called from [/tasks#{view}] page" do
          @task = Factory.build(:task, :user => @current_user)
          Task.stub!(:new).and_return(@task)

          request.env["HTTP_REFERER"] = "http://localhost/tasks#{view}"
          xhr :post, :create, :task => { :name => "Hello world" }
          assigns[:task_total].should be_an_instance_of(Hash)
        end
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved task as @lead and still render [create] template" do
        @task = Factory.build(:task, :name => nil, :user => @current_user)
        Task.stub!(:new).and_return(@task)

        xhr :post, :create, :task => {}
        assigns(:task).should == @task
        assigns(:view).should == "pending"
        assigns[:task_total].should == nil
        response.should render_template("tasks/create")
      end

    end

  end

  # PUT /tasks/1
  # PUT /tasks/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested task, expose it as @task, and render [update] template" do
        @task = Factory(:task, :id => 42, :name => "Hi", :user => @current_user)

        xhr :put, :update, :id => 42, :task => { :name => "Hello" }
        @task.reload.name.should == "Hello"
        assigns(:task).should == @task
        assigns(:view).should == "pending"
        assigns[:task_total].should == nil
        response.should render_template("tasks/update")
      end

      [ "", "?view=pending", "?view=assigned", "?view=completed" ].each do |view|
        it "should update tasks sidebar when [update] is being called from [/tasks#{view}] page" do
          @task = Factory(:task, :id => 42, :name => "Hi", :user => @current_user)

          request.env["HTTP_REFERER"] = "http://localhost/tasks#{view}"
          xhr :put, :update, :id => 42, :task => { :name => "Hello" }
          assigns[:task_total].should be_an_instance_of(Hash)
        end
      end

    end

    describe "with invalid params" do

      it "should not update the task, but still expose it as @task and render [update] template" do
        @task = Factory(:task, :id => 42, :name => "Hi", :user => @current_user)

        xhr :put, :update, :id => 42, :task => { :name => nil }
        @task.reload.name.should == "Hi"
        assigns(:task).should == @task
        assigns(:view).should == "pending"
        assigns[:task_total].should == nil
        response.should render_template("tasks/update")
      end

    end

  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do

    it "should destroy the requested task and render [destroy] template" do
      @task = Factory(:task, :id => 42, :user => @current_user)

      xhr :delete, :destroy, :id => 42, :bucket => "due_asap"
      assigns(:task).should == @task
      assigns(:view).should == "pending"
      assigns[:task_total].should == nil
      response.should render_template("tasks/destroy")
    end

    [ "", "?view=pending", "?view=assigned", "?view=completed" ].each do |view|
      it "should update sidebar when [destroy] is being called from [/tasks#{view}]" do
        @task = Factory(:task, :id => 42, :user => @current_user)

        request.env["HTTP_REFERER"] = "http://localhost/tasks#{view}"
        xhr :delete, :destroy, :id => 42, :bucket => "due_asap"
        assigns[:task_total].should be_an_instance_of(Hash)
      end
    end

    it "should not update sidebar when [destroy] is being called from asset page" do
      @task = Factory(:task, :id => 42, :user => @current_user)

      xhr :delete, :destroy, :id => 42
      assigns[:task_total].should == nil
    end

  end

  # PUT /tasks/1/complete
  # PUT /leads/1/complete.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT complete" do

    it "should change task status, expose task as @task, and render [complete] template" do
      @task = Factory(:task, :completed_at => nil, :id => 42, :user => @current_user)

      xhr :put, :complete, :id => 42
      @task.reload.completed_at.should_not == nil
      assigns[:task].should == @task
      assigns[:task_total].should == nil
      response.should render_template("tasks/complete")
    end

    it "should change update tasks sidebar if bucket is not empty" do
      @task = Factory(:task, :completed_at => nil, :id => 42, :user => @current_user)

      xhr :put, :complete, :id => 42, :bucket => "due_asap"
      assigns[:task_total].should be_an_instance_of(Hash)
    end

  end

  # Ajax request to filter out a list of tasks.                            AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET filter" do

    VIEWS.each do |view|
      it "should remove a filter from session and render [filter] template for #{view} view" do
        name = "filter_by_task_#{view}"
        session[name] = "due_asap,due_today,due_tomorrow"

        xhr :get, :filter, :filter => "due_asap", :view => view
        session[name].should_not include("due_asap")
        session[name].should include("due_today")
        session[name].should include("due_tomorrow")
        response.should render_template("tasks/filter")
      end

      it "should add a filter from session and render [filter] template for #{view} view" do
        name = "filter_by_task_#{view}"
        session[name] = "due_today,due_tomorrow"

        xhr :get, :filter, :checked => "true", :filter => "due_asap", :view => view
        session[name].should include("due_asap")
        session[name].should include("due_today")
        session[name].should include("due_tomorrow")
        response.should render_template("tasks/filter")
      end
    end

  end

end
