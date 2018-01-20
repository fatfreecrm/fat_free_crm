# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/complete" do
  include TasksHelper

  before do
    login
    assign(:bucket, [])
  end

  describe "complete from Tasks tab (pending view)" do
    before do
      @task = build_stubbed(:task)
      assign(:task, @task)
      assign(:view, "pending")
      assign(:empty_bucket, :due_asap)
      assign(:task_total, stub_task_total("pending"))
    end

    it "should fade out completed task partial" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      expect(rendered).to include("$('#task_#{@task.id}').fadeOut")
      expect(rendered).to include("$('#list_due_asap').fadeOut")
    end

    it "should update tasks sidebar" do
      assign(:task, build_stubbed(:task))
      assign(:view, "pending")
      assign(:empty_bucket, :due_asap)
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      expect(rendered).to include("$('#sidebar').html")
      expect(rendered).to have_text("Assigned")
      expect(rendered).to have_text("Recent Items")
      expect(rendered).to include("$('#filters').effect('shake'")
    end
  end

  describe "complete from related asset" do
    it "should replace pending partial with the completed one" do
      @task = build_stubbed(:task, completed_at: Time.now, completor: current_user)
      assign(:task, @task)

      render
      expect(rendered).to include("$('#task_#{@task.id}').html('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'")
      expect(rendered).to include('<strike>')
    end

    it "should update recently viewed items" do
      @task = build_stubbed(:task, completed_at: Time.now, completor: current_user)
      assign(:task, @task)
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"

      render
      expect(rendered).to have_text("Recent Items")
    end
  end
end
