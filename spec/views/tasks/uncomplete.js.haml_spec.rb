# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/uncomplete" do
  include TasksHelper

  before do
    login_and_assign
    assign(:bucket, [])
  end

  describe "uncomplete from Tasks tab (completed view)" do
    before do
      @task = FactoryGirl.create(:task)
      assign(:task, @task)
      assign(:view, "completed")
      assign(:empty_bucket, :due_asap)
      assign(:task_total, stub_task_total("completed"))
    end

    it "should slide up uncompleted task partial" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      rendered.should include("$('#task_#{@task.id}').slideUp")
      rendered.should include("$('#list_due_asap').fadeOut")
    end

    it "should update tasks sidebar" do
      assign(:task, FactoryGirl.create(:task))
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      rendered.should include("$('#sidebar').html")
      rendered.should have_text("Assigned")
      rendered.should have_text("Recent Items")
      rendered.should include("$('#filters').effect('shake'")
    end
  end
end
