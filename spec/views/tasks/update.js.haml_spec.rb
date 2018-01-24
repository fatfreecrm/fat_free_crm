# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/update" do
  include TasksHelper

  before do
    login
  end

  describe "Changing due date" do
    before do
      assign(:task_before_update, build_stubbed(:task, bucket: "due_asap"))
      assign(:task, @task = build_stubbed(:task, bucket: "due_tomorrow"))
      assign(:view, "pending")
      assign(:task_total, stub_task_total("pending"))
    end

    it "from Tasks tab: should remove task from current bucket and hide empty bucket" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render

      expect(rendered).to include(%/$('#task_#{@task.id}').remove();/)
      expect(rendered).to include(%/$('#list_due_asap').fadeOut/)
    end

    it "from Tasks tab: should show updated task in a new bucket" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render
      expect(rendered).to include("$('#due_tomorrow').prepend('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'")
      expect(rendered).to include("$('#task_#{@task.id}').effect('highlight'")
    end

    it "from Tasks tab: should update tasks sidebar" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render

      expect(rendered).to include("$('#due_tomorrow').prepend('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'")
      expect(rendered).to have_text("Assigned")
      expect(rendered).to have_text("Recent Items")
      expect(rendered).to include("$('#filters').effect('shake'")
    end

    it "from asset page: should update task partial in place" do
      render
      expect(rendered).to include("$('#task_#{@task.id}').html('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'")
    end

    it "from asset page: should update recently viewed items" do
      render
      expect(rendered).to have_text("Recent Items")
    end
  end

  describe "Reassigning" do
    before do
      assign(:task_total, stub_task_total("pending"))
    end

    it "pending task to somebody from Tasks tab: should remove the task and show flash message (assigned)" do
      assignee = build_stubbed(:user)
      assign(:task_before_update, build_stubbed(:task, assignee: nil))
      assign(:task, @task = build_stubbed(:task, assignee: assignee))
      assign(:view, "pending")
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      expect(rendered).to include("$('#task_#{@task.id}').remove();")
      expect(rendered).to have_text("view assigned tasks")
      expect(rendered).to include("$('#flash').html")
      expect(rendered).to include("crm.flash('notice', true)")
    end

    it "assigned tasks to me from Tasks tab: should remove the task and show flash message (pending)" do
      assignee = build_stubbed(:user)
      assign(:task_before_update, build_stubbed(:task, assignee: assignee))
      assign(:task, @task = build_stubbed(:task, assignee: nil))
      assign(:view, "assigned")
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"

      render
      expect(rendered).to include("$('#task_#{@task.id}').remove();")
      expect(rendered).to have_text("view pending tasks")
      expect(rendered).to include("$('#flash').html")
      expect(rendered).to include("crm.flash('notice', true)")
    end

    it "assigned tasks to somebody else from Tasks tab: should re-render task partial" do
      assign(:task_before_update, build_stubbed(:task, assignee: build_stubbed(:user)))
      assign(:task, @task = build_stubbed(:task, assignee: build_stubbed(:user)))
      assign(:view, "assigned")
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"

      render
      expect(rendered).to include("$('#task_#{@task.id}').html('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'")
    end

    it "from Tasks tab: should update tasks sidebar" do
      assign(:task_before_update, build_stubbed(:task, assignee: nil))
      assign(:task, @task = build_stubbed(:task, assignee: build_stubbed(:user)))
      assign(:view, "assigned")
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
      render

      expect(rendered).to include("$('#sidebar').html")
      expect(rendered).to have_text("Recent Items")
      expect(rendered).to have_text("Assigned")
      expect(rendered).to include("$('#filters').effect('shake'")
    end

    it "from asset page: should should re-render task partial" do
      assign(:task_before_update, build_stubbed(:task, assignee: nil))
      assign(:task, @task = build_stubbed(:task, assignee: build_stubbed(:user)))
      render

      expect(rendered).to include("$('#task_#{@task.id}').html('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'")
    end

    it "from asset page: should update recently viewed items" do
      assign(:task_before_update, build_stubbed(:task, assignee: nil))
      assign(:task, @task = build_stubbed(:task, assignee: build_stubbed(:user)))
      render

      expect(rendered).to have_text("Recent Items")
    end
  end

  it "error: should re-disiplay [Edit Task] form and shake it" do
    assign(:task_before_update, build_stubbed(:task))
    assign(:task, @task = build_stubbed(:task))
    @task.errors.add(:name)

    render
    expect(rendered).to include(%/$('#task_#{@task.id}').effect("shake"/)
    expect(rendered).to include("$('#task_submit').enable()")
  end
end
