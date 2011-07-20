require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do

  def update_sidebar
    @task_total = { :key => :value, :pairs => :etc }
    Task.stub!(:totals).and_return(@task_total)
  end

  def produce_tasks(user, view)
    #~ Time.zone = 'UTC'
    settings = (view != "completed" ? Setting.task_bucket : Setting.task_completed)

    settings.inject({}) do | hash, due |
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
            Date.yesterday + 1.day
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

    before do
      update_sidebar
      @timezone, Time.zone = Time.zone, :utc
    end

    after do
      Time.zone = @timezone
    end

    TASK_STATUSES.each do |view|
      it "should expose all tasks as @tasks and render [index] template for #{view} view" do
        @tasks = produce_tasks(@current_user, view)

        get :index, :view => view

        (assigns[:tasks].keys.map(&:to_sym) - @tasks.keys).should == []
        (assigns[:tasks].values.flatten - @tasks.values.flatten).should == []
        assigns[:task_total].symbolize_keys.should == @task_total
        response.should render_template("tasks/index")
      end

      it "should render all tasks as xml for #{view} view" do
        @tasks = produce_tasks(@current_user, view)

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index, :view => view

        (assigns[:tasks].keys.map(&:to_sym) - @tasks.keys).should == []
        (assigns[:tasks].values.flatten - @tasks.values.flatten).should == []
        hash = Hash.from_xml(response.body)
        hash["hash"].keys.each do |key|
          hash["hash"][key].each do |attr|
            task = Task.new(attr)
            task.should be_instance_of(Task)
            task.valid?.should == true
          end
        end
      end
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    TASK_STATUSES.each do |view|
      it "should render tasks index for #{view} view (since a task doesn't have landing page)" do
        get :show, :id => 42, :view => view
        response.should render_template("tasks/index")
      end

      it "should render the requested task as xml for #{view} view" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @task = Factory(:task, :user => @current_user)

        get :show, :id => @task.id, :view => "pending"
        response.body.should == @task.reload.to_xml
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
      @bucket = Setting.unroll(:task_bucket)[1..-1] << [ "On Specific Date...", :specific_time ]
      @category = Setting.unroll(:task_category)

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

    describe "(when creating related task)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @account = Factory(:account)
        @account.destroy

        xhr :get, :new, :related => "account_#{@account.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/accounts";'
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @account = Factory(:account, :access => "Private")

        xhr :get, :new, :related => "account_#{@account.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/accounts";'
      end
    end
  end

  # GET /tasks/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    it "should expose the requested task as @task and render [edit] template" do
      @asset = Factory(:account, :user => @current_user)
      @task = Factory(:task, :user => @current_user, :asset => @asset)
      @users = [ Factory(:user) ]
      @bucket = Setting.unroll(:task_bucket)[1..-1] << [ "On Specific Date...", :specific_time ]
      @category = Setting.unroll(:task_category)

      xhr :get, :edit, :id => @task.id
      assigns[:task].should == @task
      assigns[:users].should == @users
      assigns[:bucket].should == @bucket
      assigns[:category].should == @category
      assigns[:asset].should == @asset
      response.should render_template("tasks/edit")
    end

    it "should find previously open task when necessary" do
      @task = Factory(:task, :user => @current_user)
      @previous = Factory(:task, :id => 999, :user => @current_user)

      xhr :get, :edit, :id => @task.id, :previous => 999
      assigns[:task].should == @task
      assigns[:previous].should == @previous
      response.should render_template("tasks/edit")
    end

    describe "(task got deleted or reassigned)" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = Factory(:task, :user => Factory(:user), :assignee => @current_user)
        @task.destroy

        xhr :get, :edit, :id => @task.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the task got reassigned" do
        @task = Factory(:task, :user => Factory(:user), :assignee => Factory(:user))

        xhr :get, :edit, :id => @task.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

    describe "(previous task got deleted or reassigned)" do
      before(:each) do
        @task = Factory(:task, :user => @current_user)
        @previous = Factory(:task, :user => Factory(:user), :assignee => @current_user)
      end

      it "should notify the view if previous task got deleted" do
        @previous.destroy

        xhr :get, :edit, :id => @task.id, :previous => @previous.id
        flash[:warning].should == nil # no warning, just silently remove the div
        assigns[:previous].should == @previous.id
        response.should render_template("tasks/edit")
      end

      it "should notify the view if previous task got reassigned" do
        @previous.update_attribute(:assignee, Factory(:user))

        xhr :get, :edit, :id => @task.id, :previous => @previous.id
        flash[:warning].should == nil
        assigns[:previous].should == @previous.id
        response.should render_template("tasks/edit")
      end
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
          assigns[:task_total].should be_an_instance_of(HashWithIndifferentAccess)
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
  describe "responding to PUT update" do

    describe "with valid params" do
      it "should update the requested task, expose it as @task, and render [update] template" do
        @task = Factory(:task, :name => "Hi", :user => @current_user)

        xhr :put, :update, :id => @task.id, :task => { :name => "Hello" }
        @task.reload.name.should == "Hello"
        assigns(:task).should == @task
        assigns(:view).should == "pending"
        assigns[:task_total].should == nil
        response.should render_template("tasks/update")
      end

      [ "", "?view=pending", "?view=assigned", "?view=completed" ].each do |view|
        it "should update tasks sidebar when [update] is being called from [/tasks#{view}] page" do
          @task = Factory(:task, :name => "Hi", :user => @current_user)

          request.env["HTTP_REFERER"] = "http://localhost/tasks#{view}"
          xhr :put, :update, :id => @task.id, :task => { :name => "Hello" }
          assigns[:task_total].should be_an_instance_of(HashWithIndifferentAccess)
        end
      end
    end

    describe "with invalid params" do
      it "should not update the task, but still expose it as @task and render [update] template" do
        @task = Factory(:task, :name => "Hi", :user => @current_user)

        xhr :put, :update, :id => @task.id, :task => { :name => nil }
        @task.reload.name.should == "Hi"
        assigns(:task).should == @task
        assigns(:view).should == "pending"
        assigns[:task_total].should == nil
        response.should render_template("tasks/update")
      end
    end

    describe "task got deleted or reassigned" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = Factory(:task, :user => Factory(:user), :assignee => @current_user)
        @task.destroy

        xhr :put, :update, :id => @task.id, :task => { :name => "Hello" }
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the task got reassigned" do
        @task = Factory(:task, :user => Factory(:user), :assignee => Factory(:user))

        xhr :put, :update, :id => @task.id, :task => { :name => "Hello" }
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do

    it "should destroy the requested task and render [destroy] template" do
      @task = Factory(:task, :user => @current_user)

      xhr :delete, :destroy, :id => @task.id, :bucket => "due_asap"
      assigns(:task).should == @task
      assigns(:view).should == "pending"
      assigns[:task_total].should == nil
      response.should render_template("tasks/destroy")
    end

    [ "", "?view=pending", "?view=assigned", "?view=completed" ].each do |view|
      it "should update sidebar when [destroy] is being called from [/tasks#{view}]" do
        @task = Factory(:task, :user => @current_user)

        request.env["HTTP_REFERER"] = "http://localhost/tasks#{view}"
        xhr :delete, :destroy, :id => @task.id, :bucket => "due_asap"
        assigns[:task_total].should be_an_instance_of(HashWithIndifferentAccess)
      end
    end

    it "should not update sidebar when [destroy] is being called from asset page" do
      @task = Factory(:task, :user => @current_user)

      xhr :delete, :destroy, :id => @task.id
      assigns[:task_total].should == nil
    end

    describe "task got deleted or reassigned" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = Factory(:task, :user => Factory(:user), :assignee => @current_user)
        @task.destroy

        xhr :delete, :destroy, :id => @task.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the task got reassigned" do
        @task = Factory(:task, :user => Factory(:user), :assignee => Factory(:user))

        xhr :delete, :destroy, :id => @task.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end
  end

  # PUT /tasks/1/complete
  # PUT /leads/1/complete.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT complete" do

    it "should change task status, expose task as @task, and render [complete] template" do
      @task = Factory(:task, :completed_at => nil, :user => @current_user)

      xhr :put, :complete, :id => @task.id
      @task.reload.completed_at.should_not == nil
      assigns[:task].should == @task
      assigns[:task_total].should == nil
      response.should render_template("tasks/complete")
    end

    it "should change task status, expose task as @task, and render [complete] template where task.bucket = 'specific_time'" do
      @task = Factory(:task, :completed_at => nil, :user => @current_user, :bucket => "specific_time", :calendar => "01/01/2010")

      xhr :put, :complete, :id => @task.id
      @task.reload.completed_at.should_not == nil
      assigns[:task].should == @task
      assigns[:task_total].should == nil
      response.should render_template("tasks/complete")
    end

    it "should change update tasks sidebar if bucket is not empty" do
      @task = Factory(:task, :completed_at => nil, :user => @current_user)

      xhr :put, :complete, :id => @task.id, :bucket => "due_asap"
      assigns[:task_total].should be_an_instance_of(HashWithIndifferentAccess)
    end

    describe "task got deleted or reassigned" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = Factory(:task, :user => Factory(:user), :assignee => @current_user)
        @task.destroy

        xhr :put, :complete, :id => @task.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the task got reassigned" do
        @task = Factory(:task, :user => Factory(:user), :assignee => Factory(:user))

        xhr :put, :complete, :id => @task.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end
  end

  # Ajax request to filter out a list of tasks.                            AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET filter" do

    TASK_STATUSES.each do |view|
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

