# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do
  def update_sidebar
    @task_total = { key: :value, pairs: :etc }
    allow(Task).to receive(:totals).and_return(@task_total)
  end

  def produce_tasks(user, view)
    settings = (view != "completed" ? Setting.task_bucket : Setting.task_completed)

    settings.each_with_object({}) do |due, hash|
      hash[due] ||= []
      if Date.tomorrow == Date.today.end_of_week && due == :due_tomorrow
        due = :due_this_week
        hash[due] ||= []
      end
      hash[due] << case view
      when "pending"
        FactoryGirl.create(:task, user: user, bucket: due.to_s)
      when "assigned"
        FactoryGirl.create(:task, user: user, bucket: due.to_s, assigned_to: 1)
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
        FactoryGirl.create(:task, user: user, bucket: due.to_s, completed_at: completed_at)
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
      @timezone = Time.zone
      Time.zone = 'UTC'
    end

    after do
      Time.zone = @timezone
    end

    TASK_STATUSES.each do |view|
      it "should expose all tasks as @tasks and render [index] template for #{view} view" do
        @tasks = produce_tasks(current_user, view)

        get :index, params: { view: view }

        expect(assigns[:tasks].keys.map(&:to_sym) - @tasks.keys).to eq([])
        expect(assigns[:tasks].values.flatten - @tasks.values.flatten).to eq([])
        expect(assigns[:task_total].symbolize_keys).to eq(@task_total)
        expect(response).to render_template("tasks/index")
      end

      it "should render all tasks as JSON for #{view} view" do
        @tasks = produce_tasks(current_user, view)
        get :index, params: { view: view, format: :json }

        expect(assigns[:tasks].keys.map(&:to_sym) - @tasks.keys).to eq([])
        expect(assigns[:tasks].values.flatten - @tasks.values.flatten).to eq([])
        hash = ActiveSupport::JSON.decode(response.body)

        hash.keys.each do |key|
          hash[key].each do |attr|
            task = Task.new(attr["task"])
            expect(task).to be_instance_of(Task)
            expect(task.valid?).to eq(true)
          end
        end
      end

      it "should render all tasks as xml for #{view} view" do
        @tasks = produce_tasks(current_user, view)
        get :index, params: { view: view, format: :xml }

        expect(assigns[:tasks].keys.map(&:to_sym) - @tasks.keys).to eq([])
        expect(assigns[:tasks].values.flatten - @tasks.values.flatten).to eq([])
        hash = Hash.from_xml(response.body)
        hash["hash"].keys.each do |key|
          hash["hash"][key].each do |attr|
            task = Task.new(attr)
            expect(task).to be_instance_of(Task)
            expect(task.valid?).to eq(true)
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
      it "should render the requested task as JSON for #{view} view" do
        allow(Task).to receive_message_chain(:tracked_by, :find).and_return(task = double("Task"))
        expect(task).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :show, params: { id: 42, view: "pending" }
        expect(response.body).to eq("generated JSON")
      end

      it "should render the requested task as xml for #{view} view" do
        allow(Task).to receive_message_chain(:tracked_by, :find).and_return(task = double("Task"))
        expect(task).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, params: { id: 42, view: "pending" }
        expect(response.body).to eq("generated XML")
      end
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do
    it "should expose a new task as @task and render [new] template" do
      account = FactoryGirl.create(:account, user: current_user)
      @task = FactoryGirl.build(:task, user: current_user, asset: account)
      allow(Task).to receive(:new).and_return(@task)
      @bucket = Setting.unroll(:task_bucket)[1..-1] << ["On Specific Date...", :specific_time]
      @category = Setting.unroll(:task_category)

      get :new, xhr: true
      expect(assigns[:task]).to eq(@task)
      expect(assigns[:bucket]).to eq(@bucket)
      expect(assigns[:category]).to eq(@category)
      expect(response).to render_template("tasks/new")
    end

    it "should find related asset when necessary" do
      @asset = FactoryGirl.create(:account, id: 42)

      get :new, params: { related: "account_42" }, xhr: true
      expect(assigns[:asset]).to eq(@asset)
      expect(response).to render_template("tasks/new")
    end

    describe "(when creating related task)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @account = FactoryGirl.create(:account)
        @account.destroy

        get :new, params: { related: "account_#{@account.id}" }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.href = "/accounts";')
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @account = FactoryGirl.create(:account, access: "Private")

        get :new, params: { related: "account_#{@account.id}" }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.href = "/accounts";')
      end
    end
  end

  # GET /tasks/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    it "should expose the requested task as @task and render [edit] template" do
      @asset = FactoryGirl.create(:account, user: current_user)
      @task = FactoryGirl.create(:task, user: current_user, asset: @asset)
      @bucket = Setting.unroll(:task_bucket)[1..-1] << ["On Specific Date...", :specific_time]
      @category = Setting.unroll(:task_category)

      get :edit, params: { id: @task.id }, xhr: true
      expect(assigns[:task]).to eq(@task)
      expect(assigns[:bucket]).to eq(@bucket)
      expect(assigns[:category]).to eq(@category)
      expect(assigns[:asset]).to eq(@asset)
      expect(response).to render_template("tasks/edit")
    end

    it "should find previously open task when necessary" do
      @task = FactoryGirl.create(:task, user: current_user)
      @previous = FactoryGirl.create(:task, id: 999, user: current_user)

      get :edit, params: { id: @task.id, previous: 999 }, xhr: true
      expect(assigns[:task]).to eq(@task)
      expect(assigns[:previous]).to eq(@previous)
      expect(response).to render_template("tasks/edit")
    end

    describe "(task got deleted or reassigned)" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: current_user)
        @task.destroy

        get :edit, params: { id: @task.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the task got reassigned" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: FactoryGirl.create(:user))

        get :edit, params: { id: @task.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end

    describe "(previous task got deleted or reassigned)" do
      before(:each) do
        @task = FactoryGirl.create(:task, user: current_user)
        @previous = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: current_user)
      end

      it "should notify the view if previous task got deleted" do
        @previous.destroy

        get :edit, params: { id: @task.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("tasks/edit")
      end

      it "should notify the view if previous task got reassigned" do
        @previous.update_attribute(:assignee, FactoryGirl.create(:user))

        get :edit, params: { id: @task.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("tasks/edit")
      end
    end
  end

  # POST /tasks
  # POST /tasks.xml                                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do
    describe "with valid params" do
      it "should expose a newly created task as @task and render [create] template" do
        @task = FactoryGirl.build(:task, user: current_user)
        allow(Task).to receive(:new).and_return(@task)

        post :create, params: { task: { name: "Hello world" } }, xhr: true
        expect(assigns(:task)).to eq(@task)
        expect(assigns(:view)).to eq("pending")
        expect(assigns[:task_total]).to eq(nil)
        expect(response).to render_template("tasks/create")
      end

      ["", "?view=pending", "?view=assigned", "?view=completed"].each do |view|
        it "should update tasks sidebar when [create] is being called from [/tasks#{view}] page" do
          @task = FactoryGirl.build(:task, user: current_user)
          allow(Task).to receive(:new).and_return(@task)

          request.env["HTTP_REFERER"] = "http://localhost/tasks#{view}"
          post :create, params: { task: { name: "Hello world" } }, xhr: true
          expect(assigns[:task_total]).to be_an_instance_of(HashWithIndifferentAccess)
        end
      end
    end

    describe "with invalid params" do
      it "should expose a newly created but unsaved task as @lead and still render [create] template" do
        @task = FactoryGirl.build(:task, name: nil, user: current_user)
        allow(Task).to receive(:new).and_return(@task)

        post :create, params: { task: {} }, xhr: true
        expect(assigns(:task)).to eq(@task)
        expect(assigns(:view)).to eq("pending")
        expect(assigns[:task_total]).to eq(nil)
        expect(response).to render_template("tasks/create")
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update" do
    describe "with valid params" do
      it "should update the requested task, expose it as @task, and render [update] template" do
        @task = FactoryGirl.create(:task, name: "Hi", user: current_user)

        put :update, params: { id: @task.id, task: { name: "Hello" } }, xhr: true
        expect(@task.reload.name).to eq("Hello")
        expect(assigns(:task)).to eq(@task)
        expect(assigns(:view)).to eq("pending")
        expect(assigns[:task_total]).to eq(nil)
        expect(response).to render_template("tasks/update")
      end

      ["", "?view=pending", "?view=assigned", "?view=completed"].each do |view|
        it "should update tasks sidebar when [update] is being called from [/tasks#{view}] page" do
          @task = FactoryGirl.create(:task, name: "Hi", user: current_user)

          request.env["HTTP_REFERER"] = "http://localhost/tasks#{view}"
          put :update, params: { id: @task.id, task: { name: "Hello" } }, xhr: true
          expect(assigns[:task_total]).to be_an_instance_of(HashWithIndifferentAccess)
        end
      end
    end

    describe "with invalid params" do
      it "should not update the task, but still expose it as @task and render [update] template" do
        @task = FactoryGirl.create(:task, name: "Hi", user: current_user)

        put :update, params: { id: @task.id, task: { name: nil } }, xhr: true
        expect(@task.reload.name).to eq("Hi")
        expect(assigns(:task)).to eq(@task)
        expect(assigns(:view)).to eq("pending")
        expect(assigns[:task_total]).to eq(nil)
        expect(response).to render_template("tasks/update")
      end
    end

    describe "task got deleted or reassigned" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: current_user)
        @task.destroy

        put :update, params: { id: @task.id, task: { name: "Hello" } }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the task got reassigned" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: FactoryGirl.create(:user))

        put :update, params: { id: @task.id, task: { name: "Hello" } }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    it "should destroy the requested task and render [destroy] template" do
      @task = FactoryGirl.create(:task, user: current_user)

      delete :destroy, params: { id: @task.id, bucket: "due_asap" }, xhr: true
      expect(assigns(:task)).to eq(@task)
      expect(assigns(:view)).to eq("pending")
      expect(assigns[:task_total]).to eq(nil)
      expect(response).to render_template("tasks/destroy")
    end

    ["", "?view=pending", "?view=assigned", "?view=completed"].each do |view|
      it "should update sidebar when [destroy] is being called from [/tasks#{view}]" do
        @task = FactoryGirl.create(:task, user: current_user)

        request.env["HTTP_REFERER"] = "http://localhost/tasks#{view}"
        delete :destroy, params: { id: @task.id, bucket: "due_asap" }, xhr: true
        expect(assigns[:task_total]).to be_an_instance_of(HashWithIndifferentAccess)
      end
    end

    it "should not update sidebar when [destroy] is being called from asset page" do
      @task = FactoryGirl.create(:task, user: current_user)

      delete :destroy, params: { id: @task.id }, xhr: true
      expect(assigns[:task_total]).to eq(nil)
    end

    describe "task got deleted or reassigned" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: current_user)
        @task.destroy

        delete :destroy, params: { id: @task.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the task got reassigned" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: FactoryGirl.create(:user))

        delete :destroy, params: { id: @task.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end
  end

  # PUT /tasks/1/complete
  # PUT /leads/1/complete.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT complete" do
    it "should change task status, expose task as @task, and render [complete] template" do
      @task = FactoryGirl.create(:task, completed_at: nil, user: current_user)

      put :complete, params: { id: @task.id }, xhr: true
      expect(@task.reload.completed_at).not_to eq(nil)
      expect(assigns[:task]).to eq(@task)
      expect(assigns[:task_total]).to eq(nil)
      expect(response).to render_template("tasks/complete")
    end

    it "should change task status, expose task as @task, and render [complete] template where task.bucket = 'specific_time'" do
      @task = FactoryGirl.create(:task, completed_at: nil, user: current_user, bucket: "specific_time", calendar: "01/01/2010 1:00 AM")

      put :complete, params: { id: @task.id }, xhr: true
      expect(@task.reload.completed_at).not_to eq(nil)
      expect(assigns[:task]).to eq(@task)
      expect(assigns[:task_total]).to eq(nil)
      expect(response).to render_template("tasks/complete")
    end

    it "should change update tasks sidebar if bucket is not empty" do
      @task = FactoryGirl.create(:task, completed_at: nil, user: current_user)

      put :complete, params: { id: @task.id, bucket: "due_asap" }, xhr: true
      expect(assigns[:task_total]).to be_an_instance_of(HashWithIndifferentAccess)
    end

    describe "task got deleted or reassigned" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: current_user)
        @task.destroy

        put :complete, params: { id: @task.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the task got reassigned" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: FactoryGirl.create(:user))

        put :complete, params: { id: @task.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end
  end

  # PUT /tasks/1/complete
  # PUT /leads/1/complete.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT uncomplete" do
    it "should change task status, expose task as @task, and render template" do
      @task = FactoryGirl.create(:task, completed_at: Time.now, user: current_user)

      put :uncomplete, params: { id: @task.id }, xhr: true
      expect(@task.reload.completed_at).to eq(nil)
      expect(assigns[:task]).to eq(@task)
      expect(assigns[:task_total]).not_to eq(nil)
      expect(response).to render_template("tasks/uncomplete")
    end

    describe "task got deleted" do
      it "should reload current page with the flash message if the task got deleted" do
        @task = FactoryGirl.create(:task, user: FactoryGirl.create(:user), assignee: current_user, completed_at: Time.now)
        @task.destroy

        put :uncomplete, params: { id: @task.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
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

        get :filter, params: { filter: "due_asap", view: view }, xhr: true
        expect(session[name]).not_to include("due_asap")
        expect(session[name]).to include("due_today")
        expect(session[name]).to include("due_tomorrow")
        expect(response).to render_template("tasks/filter")
      end

      it "should add a filter from session and render [filter] template for #{view} view" do
        name = "filter_by_task_#{view}"
        session[name] = "due_today,due_tomorrow"

        get :filter, params: { checked: "true", filter: "due_asap", view: view }, xhr: true
        expect(session[name]).to include("due_asap")
        expect(session[name]).to include("due_today")
        expect(session[name]).to include("due_tomorrow")
        expect(response).to render_template("tasks/filter")
      end
    end
  end
end
