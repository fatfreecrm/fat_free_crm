# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/complete" do
  include TasksHelper

  before do
    login_and_assign
    assign(:bucket, [])
  end

  describe "complete from Tasks tab (pending view)" do
    before do
      @task = FactoryGirl.create(:task)
      assign(:task, @task)
      assign(:view, "pending")
      assign(:empty_bucket, :due_asap)
      assign(:task_total, stub_task_total("pending"))
    end

    it "should fade out completed task partial" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      rendered.should include("$('#task_#{@task.id}').fadeOut")
      rendered.should include("$('#list_due_asap').fadeOut")
    end

    it "should update tasks sidebar" do
      assign(:task, FactoryGirl.create(:task))
      assign(:view, "pending")
      assign(:empty_bucket, :due_asap)
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      rendered.should include("$('#sidebar').html")
      rendered.should have_text("Assigned")
      rendered.should have_text("Recent Items")
      rendered.should include("$('#filters').effect('shake'")
    end
  end

  describe "complete from related asset" do
    it "should replace pending partial with the completed one" do
      @task = FactoryGirl.create(:task, :completed_at => Time.now, :completor => current_user)
      assign(:task, @task)

      render
      rendered.should include("$('#task_#{@task.id}').html('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'")
      rendered.should include('<strike>')
    end

    it "should update recently viewed items" do
      @task = FactoryGirl.create(:task, :completed_at => Time.now, :completor => current_user)
      assign(:task, @task)
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"

      render
      rendered.should have_text("Recent Items")
    end
  end

end
