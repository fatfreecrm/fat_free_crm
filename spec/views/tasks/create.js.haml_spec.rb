# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/create" do
  include TasksHelper

  before do
    login_and_assign
  end

  (TASK_STATUSES - %w(completed)).each do |status|
    describe "create from #{status} tasks page" do
      before do
        assign(:view, status)
        assign(:task, @task = stub_task(status))
        assign(:task_total, stub_task_total(status))
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=#{status}"
        render
      end

      it "should hide [Create Task] form and insert task partial" do
        rendered.should include(%Q/$('#due_asap').before('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'>/)
        rendered.should include(%Q/$('#task_#{@task.id}').effect("highlight"/)
      end

      it "should update tasks title" do
        if status == "assigned"
          rendered.should include("$('#title').html('Assigned Tasks');")
        else
          rendered.should include("$('#title').html('Tasks');")
        end
      end

      it "should update tasks sidebar" do
        rendered.should include("$('#sidebar').html")
        rendered.should have_text("Recent Items")
        rendered.should have_text("Sometime Later")
        rendered.should include("$('#filters').effect('shake'")
      end
    end
  end

  it "should show flash message when assigning a task from pending tasks view" do
    assign(:view, "pending")
    assign(:task, FactoryGirl.create(:task, :id => 42, :assignee => FactoryGirl.create(:user)))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render

    rendered.should include("$('#flash').html")
    rendered.should include("crm.flash('notice', true)")
  end

  it "should update recent items when assigning a task from pending tasks view" do
    assign(:view, "pending")
    assign(:task, FactoryGirl.create(:task, :id => 42, :assignee => FactoryGirl.create(:user)))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render

    rendered.should include("#recently")
    rendered.should have_text("Recent Items")
  end

  it "should show flash message when creating a pending task from assigned tasks view" do
    assign(:view, "assigned")
    assign(:task, FactoryGirl.create(:task, :id => 42, :assignee => nil))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render

    rendered.should include("$('#flash').html")
    rendered.should include("crm.flash('notice', true)")
  end

  it "should update recent items when creating a pending task from assigned tasks view" do
    assign(:view, "assigned")
    assign(:task, FactoryGirl.create(:task, :id => 42, :assignee => nil))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render

    rendered.should include("#recently")
    rendered.should have_text("Recent Items")
  end

  (TASK_STATUSES - %w(assigned)).each do |status|
    describe "create from outside the Tasks tab" do
      before do
        @task = FactoryGirl.create(:task, :id => 42)
        assign(:view, status)
        assign(:task, @task)
        render
      end

      it "should update tasks title" do
        rendered.should include("$('#create_task_title').html('Tasks')")
      end

      it "should insert #{status} partial and highlight it" do
        rendered.should include("$('#tasks').prepend('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'>")
        rendered.should include(%Q/$('#task_#{@task.id}').effect("highlight"/)
      end

      it "should update recently viewed items" do
        rendered.should include("#recently")
        rendered.should have_text("Recent Items")
      end
    end
  end

  it "create failure: should re-render [create] template in :create_task div" do
    assign(:task, FactoryGirl.build(:task, :name => nil)) # make it invalid
    render

    rendered.should include(%Q/$('#create_task').effect("shake"/)
    rendered.should include(%/$('#new_task input[type=submit]').enable()/)

  end

end
