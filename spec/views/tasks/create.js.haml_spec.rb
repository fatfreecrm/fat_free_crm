# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/create" do
  include TasksHelper

  before do
    login
  end

  (TASK_STATUSES - ['completed']).each do |status|
    describe "create from #{status} tasks page" do
      before do
        assign(:view, status)
        assign(:task, @task = stub_task(status))
        assign(:task_total, stub_task_total(status))
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=#{status}"
        render
      end

      it "should hide [Create Task] form and insert task partial" do
        expect(rendered).to include(%/$('#due_asap').before('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'>/)
        expect(rendered).to include(%/$('#task_#{@task.id}').effect("highlight"/)
      end

      it "should update tasks title" do
        if status == "assigned"
          expect(rendered).to include("$('#title').html('Assigned Tasks');")
        else
          expect(rendered).to include("$('#title').html('Tasks');")
        end
      end

      it "should update tasks sidebar" do
        expect(rendered).to include("$('#sidebar').html")
        expect(rendered).to have_text("Recent Items")
        expect(rendered).to have_text("Sometime Later")
      end
    end
  end

  it "should show flash message when assigning a task from pending tasks view" do
    assign(:view, "pending")
    assign(:task, build_stubbed(:task, id: 42, assignee: build_stubbed(:user)))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render

    expect(rendered).to include("$('#flash').html")
    expect(rendered).to include("crm.flash('notice', true)")
  end

  it "should update recent items when assigning a task from pending tasks view" do
    assign(:view, "pending")
    assign(:task, build_stubbed(:task, id: 42, assignee: build_stubbed(:user)))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render

    expect(rendered).to include("#recently")
    expect(rendered).to have_text("Recent Items")
  end

  it "should show flash message when creating a pending task from assigned tasks view" do
    assign(:view, "assigned")
    assign(:task, build_stubbed(:task, id: 42, assignee: nil))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render

    expect(rendered).to include("$('#flash').html")
    expect(rendered).to include("crm.flash('notice', true)")
  end

  it "should update recent items when creating a pending task from assigned tasks view" do
    assign(:view, "assigned")
    assign(:task, build_stubbed(:task, id: 42, assignee: nil))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render

    expect(rendered).to include("#recently")
    expect(rendered).to have_text("Recent Items")
  end

  (TASK_STATUSES - ['assigned']).each do |status|
    describe "create from outside the Tasks tab" do
      before do
        @task = build_stubbed(:task, id: 42)
        assign(:view, status)
        assign(:task, @task)
        render
      end

      it "should update tasks title" do
        expect(rendered).to include("$('#create_task_title').html('Tasks')")
      end

      it "should insert #{status} partial and highlight it" do
        expect(rendered).to include("$('#tasks').prepend('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'>")
        expect(rendered).to include(%/$('#task_#{@task.id}').effect("highlight"/)
      end

      it "should update recently viewed items" do
        expect(rendered).to include("#recently")
        expect(rendered).to have_text("Recent Items")
      end
    end
  end

  it "create failure: should re-render [create] template in :create_task div" do
    assign(:task, build(:task, name: nil)) # make it invalid
    render

    expect(rendered).to include(%/$('#new_task input[type=submit]').enable()/)
  end
end
