# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/edit" do
  include TasksHelper

  before do
    login_and_assign
    assign(:users, [ current_user ])
    assign(:bucket, Setting.task_bucket[1..-1] << [ "On Specific Date...", :specific_time ])
    assign(:category, Setting.unroll(:task_category))
  end


  %w(pending assigned).each do |view|
    it "cancel for #{view} view: should replace [Edit Task] form with the task partial" do
      params[:cancel] = "true"
      @task = stub_task(view)
      assign(:view, view)
      assign(:task, @task)

      render
      rendered.should include("$('#task_#{@task.id}').html('<li class=\\'highlight task\\' id=\\'task_#{@task.id}\\'")
      if view == "pending"
        rendered.should include('type=\\"checkbox\\"')
      else
        rendered.should_not include('type=\\"checkbox\\"')
      end
    end

    it "edit: should hide [Create Task] form" do
      assign(:view, view)
      assign(:task, stub_task(view))

      render
      rendered.should include("crm.hide_form('create_task'")
    end

    it "edit: should hide previously open [Edit Task] form" do
      @previous = stub_task(view)
      assign(:previous, @previous)
      assign(:view, view)
      assign(:task, stub_task(view))

      render
      rendered.should include("$('#task_#{@previous.id}').replaceWith")
    end

    it "edit: should remove previous [Edit Task] form if previous task is not available" do
      @previous = stub_task(view)
      assign(:previous, 41)
      assign(:view, view)
      assign(:task, stub_task(view))

      render
      rendered.should include("crm.flick('task_41', 'remove');")
    end

    it "edit: should turn off highlight and replace current task with [Edit Task] form" do
      @task = stub_task(view)
      assign(:view, view)
      assign(:task, @task)

      render
      rendered.should include("crm.highlight_off('task_#{@task.id}');")
      rendered.should include("$('#task_#{@task.id}').html")
      rendered.should have_text("On Specific Date")
      rendered.should include("$('#task_name').focus();")
    end

  end

end
