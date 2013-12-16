# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/new" do
  include TasksHelper

  before do
    login_and_assign
    assign(:task, FactoryGirl.build(:task))
    assign(:users, [ current_user ])
    assign(:bucket, Setting.task_bucket[1..-1] << [ "On Specific Date...", :specific_time ])
    assign(:category, Setting.unroll(:task_category))
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include("crm.flick('empty', 'toggle')")
  end

  describe "new task" do
    before { @task_with_time = Setting.task_calendar_with_time }
    after  { Setting.task_calendar_with_time = @task_with_time }

    it "create: should render [new] template into :create_task div" do
      params[:cancel] = nil
      render

      rendered.should include("$('#create_task').html")
      rendered.should include("crm.flip_form('create_task');")
    end
  end

  describe "cancel new task" do
    it "should hide [create task] form" do
      params[:cancel] = "true"
      render

      rendered.should_not include("$('#create_task').html")
      rendered.should include("crm.flip_form('create_task');")
    end
  end

end
