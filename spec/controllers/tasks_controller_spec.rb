require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do

  def update_sidebar
    @task_total = Task.stub!(:totals).and_return({ :key => :value })
  end

  before(:each) do
    require_user
    set_current_tab(:tasks)
    @uuid = "12345678-0123-5678-0123-567890123456"
  end

  def mock_task(stubs={})
    @mock_task ||= mock_model(Task, stubs)
  end
  
  describe "responding to GET index" do

    before(:each) do
      update_sidebar
    end

    it "should expose all tasks as @tasks" do
      Task.should_receive(:find_all_grouped).with(@current_user, "pending").and_return([mock_task])
      Setting.should_receive(:task_due_at_hint).and_return([[ "key", :value ]])
      Setting.should_receive(:task_category).and_return({ :key => :value })
      User.should_receive(:all_except).with(@current_user) if @view == "assigned"
      get :index, :view => "pending"
      assigns[:tasks].should == [mock_task]
    end

    describe "with mime type of xml" do
  
      it "should render all tasks as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Task.should_receive(:find_all_grouped).with(@current_user, "assigned").and_return(tasks = mock("Array of Tasks"))
        Setting.should_receive(:task_due_at_hint).and_return([[ "key", :value ]])
        Setting.should_receive(:task_category).and_return({ :key => :value })
        User.should_receive(:all_except).with(@current_user) if @view == "assigned"
        tasks.should_receive(:to_xml).and_return("generated XML")
        get :index, :view => "assigned"
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested task as @task" do
      Task.should_receive(:find).with("37").and_return(mock_task)
      get :show, :id => "37"
      assigns[:task].should equal(mock_task)
    end
    
    describe "with mime type of xml" do

      it "should render the requested task as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Task.should_receive(:find).with("37").and_return(mock_task)
        mock_task.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new task as @task" do
      Task.should_receive(:new).and_return(mock_task)
      get :new
      assigns[:task].should equal(mock_task)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested task as @task" do
      Task.should_receive(:find).with("37").and_return(mock_task)
      get :edit, :id => "37"
      assigns[:task].should equal(mock_task)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      before(:each) do
        update_sidebar
      end

      it "should expose a newly created task as @task" do
        @task = mock_task(:save => true, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
        Task.should_receive(:new).with({'these' => 'params'}).and_return(@task)
        @task.should_receive(:hint).and_return("due_later")
        post :create, :task => {:these => 'params'}
        assigns(:task).should equal(mock_task)
      end

      it "should render 'create' template" do
        @task = mock_task(:save => true, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
        Task.stub!(:new).and_return(@task)
        @task.should_receive(:hint).and_return("due_later")
        post :create, :task => {}
        response.should render_template('create')
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved task as @task" do
        @task = mock_task(:save => false, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
        Task.stub!(:new).with({'these' => 'params'}).and_return(@task)
        post :create, :task => {:these => 'params'}
        assigns(:task).should equal(mock_task)
      end

      it "should re-render the 'create' template" do
        @task = mock_task(:save => false, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
        Task.stub!(:new).and_return(@task)
        post :create, :task => {}
        response.should render_template('create')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested task" do
        Task.should_receive(:find).with("37").and_return(mock_task)
        mock_task.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :task => {:these => 'params'}
      end

      it "should expose the requested task as @task" do
        Task.stub!(:find).and_return(mock_task(:update_attributes => true))
        put :update, :id => "1"
        assigns(:task).should equal(mock_task)
      end

      it "should redirect to the task" do
        Task.stub!(:find).and_return(mock_task(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(task_url(mock_task))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested task" do
        Task.should_receive(:find).with("37").and_return(mock_task)
        mock_task.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :task => {:these => 'params'}
      end

      it "should expose the task as @task" do
        Task.stub!(:find).and_return(mock_task(:update_attributes => false))
        put :update, :id => "1"
        assigns(:task).should equal(mock_task)
      end

      it "should re-render the 'edit' template" do
        Task.stub!(:find).and_return(mock_task(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    before(:each) do
      update_sidebar
    end

    it "should destroy the requested task" do
      @task = mock_task(:deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
      Task.should_receive(:find).with("42").and_return(@task)
      Task.should_receive(:bucket).with(@current_user, "due_asap", "pending").and_return(nil)
      @task.should_receive(:hint).and_return("due_later")
      mock_task.should_receive(:destroy)
      delete :destroy, :id => "42", :bucket => "due_asap", :view => "pending"
    end
  
    it "should render 'destroy' template" do
      @task = mock_task(:destroy => true, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
      Task.should_receive(:find).with("42").and_return(@task)
      Task.should_receive(:bucket).with(@current_user, "due_today", "assigned").and_return(nil)
      @task.should_receive(:hint).and_return("due_later")
      delete :destroy, :id => "42", :bucket => "due_today", :view => "assigned"
      response.should render_template('destroy')
    end

  end

end
