# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/tasks/uncomplete" do

    before do
      login
      assign(:bucket, [])
    end

    describe "uncomplete from Tasks tab (completed view)" do
      before do
        @task = build_stubbed(:task)
        assign(:task, @task)
        assign(:view, "completed")
        assign(:empty_bucket, :due_asap)
        assign(:task_total, stub_task_total("completed"))
      end

      it "should slide up out destroyed task partial" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/fat_free_crm/tasks"

        render
        expect(rendered).to include("$('#task_#{@task.id}').slideUp")
        expect(rendered).to include("$('#list_due_asap').fadeOut")
      end

      it "should update tasks sidebar" do
        assign(:task, build_stubbed(:task))
        controller.request.env["HTTP_REFERER"] = "http://localhost/fat_free_crm/tasks"

        render
        expect(rendered).to include("$('#sidebar').html")
        expect(rendered).to have_text("Assigned")
        expect(rendered).to have_text("Recent Items")
        expect(rendered).to include("$('#filters').effect('shake'")
      end
    end
  end

  describe "destroy from related asset" do
    it "should blind up out destroyed task partial" do
      @task = build_stubbed(:task)
      assign(:task, @task)
      controller.request.env["HTTP_REFERER"] = "http://localhost/fat_free_crm/leads/123"

      render
      expect(rendered).to include("slideUp")
      expect(rendered).not_to include("fadeOut") # bucket is not empty
    end
  end
end
