require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do

  def update_sidebar
    @task_total = { :key => :value, :pairs => :etc }
    Task.stub!(:totals).and_return(@task_total)
  end

  def produce_tasks(user, view)
    Setting.as_hash(:task_due_at_hint).keys.inject({}) do | hash, due |
      hash[due] = case view
      when "pending"
        [ Factory(:task, :user => user, :asset => Factory(:account), :due_at_hint => due.to_s, :assigned_to => nil) ]
      when "assigned"
        [ Factory(:task, :user => user, :asset => Factory(:account), :due_at_hint => due.to_s, :assigned_to => 1) ]
      when "completed"
        [ Factory(:task, :user => user, :asset => Factory(:account), :due_at_hint => due.to_s, :completed_at => Time.now) ]
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

    it "should expose all tasks as @tasks and render [index] template" do
      @tasks = produce_tasks(@current_user, "pending")

      get :index, :view => "pending"
      assigns[:tasks].keys.should == @tasks.keys
      (assigns[:tasks].values - @tasks.values).should == []
      assigns[:task_total].should == @task_total
      response.should render_template("tasks/index")
    end

    describe "with mime type of xml" do

      it "should render all tasks as xml" do
        @tasks = produce_tasks(@current_user, "pending")

        # Convert symbol keys to strings, otherwise to_xml fails (Rails 2.2).
        @tasks = @tasks.inject({}) { |tasks, (k,v)| tasks[k.to_s] = v; tasks }

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index, :view => "pending"
        response.body.should == @tasks.to_xml
      end

    end

  end

  # GET /tasks/1
  # GET /tasks/1.xml
  #----------------------------------------------------------------------------
  # describe "responding to GET show" do
  # 
  #   it "should expose the requested task as @task" do
  #     Task.should_receive(:find).with("37").and_return(mock_task)
  #     get :show, :id => "37"
  #     assigns[:task].should equal(mock_task)
  #   end
  #   
  #   describe "with mime type of xml" do
  # 
  #     it "should render the requested task as xml" do
  #       request.env["HTTP_ACCEPT"] = "application/xml"
  #       Task.should_receive(:find).with("37").and_return(mock_task)
  #       mock_task.should_receive(:to_xml).and_return("generated XML")
  #       get :show, :id => "37"
  #       response.body.should == "generated XML"
  #     end
  # 
  #   end
  #   
  # end
  # 
  # # GET /tasks/new
  # # GET /tasks/new.xml                                                     AJAX
  # #----------------------------------------------------------------------------
  # describe "responding to GET new" do
  # 
  #   it "should expose a new task as @task" do
  #     Task.should_receive(:new).and_return(mock_task)
  #     get :new
  #     assigns[:task].should equal(mock_task)
  #   end
  # 
  # end
  # 
  # # GET /tasks/1/edit                                                      AJAX
  # #----------------------------------------------------------------------------
  # describe "responding to GET edit" do
  # 
  #   it "should expose the requested task as @task" do
  #     Task.should_receive(:find).with("37").and_return(mock_task)
  #     get :edit, :id => "37"
  #     assigns[:task].should equal(mock_task)
  #   end
  # 
  # end
  # 
  # # POST /tasks
  # # POST /tasks.xml                                                        AJAX
  # #----------------------------------------------------------------------------
  # describe "responding to POST create" do
  # 
  #   describe "with valid params" do
  #     
  #     before(:each) do
  #       update_sidebar
  #     end
  # 
  #     it "should expose a newly created task as @task" do
  #       @task = mock_task(:save => true, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
  #       Task.should_receive(:new).with({'these' => 'params'}).and_return(@task)
  #       @task.should_receive(:hint).and_return("due_later")
  #       post :create, :task => {:these => 'params'}
  #       assigns(:task).should equal(mock_task)
  #     end
  # 
  #     it "should render 'create' template" do
  #       @task = mock_task(:save => true, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
  #       Task.stub!(:new).and_return(@task)
  #       @task.should_receive(:hint).and_return("due_later")
  #       post :create, :task => {}
  #       response.should render_template('create')
  #     end
  #     
  #   end
  #   
  #   describe "with invalid params" do
  # 
  #     it "should expose a newly created but unsaved task as @task" do
  #       @task = mock_task(:save => false, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
  #       Task.stub!(:new).with({'these' => 'params'}).and_return(@task)
  #       post :create, :task => {:these => 'params'}
  #       assigns(:task).should equal(mock_task)
  #     end
  # 
  #     it "should re-render the 'create' template" do
  #       @task = mock_task(:save => false, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
  #       Task.stub!(:new).and_return(@task)
  #       post :create, :task => {}
  #       response.should render_template('create')
  #     end
  #     
  #   end
  #   
  # end
  # 
  # # PUT /tasks/1
  # # PUT /tasks/1.xml                                                       AJAX
  # #----------------------------------------------------------------------------
  # describe "responding to PUT udpate" do
  # 
  #   describe "with valid params" do
  # 
  #     it "should update the requested task" do
  #       Task.should_receive(:find).with("37").and_return(mock_task)
  #       mock_task.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :task => {:these => 'params'}
  #     end
  # 
  #     it "should expose the requested task as @task" do
  #       Task.stub!(:find).and_return(mock_task(:update_attributes => true))
  #       put :update, :id => "1"
  #       assigns(:task).should equal(mock_task)
  #     end
  # 
  #     it "should redirect to the task" do
  #       Task.stub!(:find).and_return(mock_task(:update_attributes => true))
  #       put :update, :id => "1"
  #       response.should redirect_to(task_url(mock_task))
  #     end
  # 
  #   end
  #   
  #   describe "with invalid params" do
  # 
  #     it "should update the requested task" do
  #       Task.should_receive(:find).with("37").and_return(mock_task)
  #       mock_task.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :task => {:these => 'params'}
  #     end
  # 
  #     it "should expose the task as @task" do
  #       Task.stub!(:find).and_return(mock_task(:update_attributes => false))
  #       put :update, :id => "1"
  #       assigns(:task).should equal(mock_task)
  #     end
  # 
  #     it "should re-render the 'edit' template" do
  #       Task.stub!(:find).and_return(mock_task(:update_attributes => false))
  #       put :update, :id => "1"
  #       response.should render_template('edit')
  #     end
  # 
  #   end
  # 
  # end
  # 
  # # DELETE /tasks/1
  # # DELETE /tasks/1.xml                                                    AJAX
  # #----------------------------------------------------------------------------
  # describe "responding to DELETE destroy" do
  # 
  #   before(:each) do
  #     update_sidebar
  #   end
  # 
  #   it "should destroy the requested task" do
  #     @task = mock_task(:deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
  #     Task.should_receive(:find).with("42").and_return(@task)
  #     Task.should_receive(:bucket).with(@current_user, "due_asap", "pending").and_return(nil)
  #     @task.should_receive(:hint).and_return("due_later")
  #     mock_task.should_receive(:destroy)
  #     delete :destroy, :id => "42", :bucket => "due_asap", :view => "pending"
  #   end
  # 
  #   it "should render 'destroy' template" do
  #     @task = mock_task(:destroy => true, :deleted_at => nil, :completed_at => nil, :due_at_hint => nil)
  #     Task.should_receive(:find).with("42").and_return(@task)
  #     Task.should_receive(:bucket).with(@current_user, "due_today", "assigned").and_return(nil)
  #     @task.should_receive(:hint).and_return("due_later")
  #     delete :destroy, :id => "42", :bucket => "due_today", :view => "assigned"
  #     response.should render_template('destroy')
  #   end
  # 
  # end
  # 
  # # PUT /tasks/1/complete
  # # PUT /leads/1/complete.xml                                              AJAX
  # #----------------------------------------------------------------------------
  # describe "responding to PUT complete" do
  # 
  #   it "should..." do
  #   end
  #   
  # end
  # 
  # # Ajax request to filter out a list of tasks.                            AJAX
  # #----------------------------------------------------------------------------
  # describe "responding to GET filter" do
  # 
  #   it "should..." do
  #   end
  #   
  # end

end
