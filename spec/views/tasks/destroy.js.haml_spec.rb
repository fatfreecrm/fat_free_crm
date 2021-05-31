# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/destroy" do
  include TasksHelper

  before do
    login
  end

  TASK_STATUSES.each do |status|
    describe "destroy from Tasks tab (#{status} view)" do
      before do
        @task = build_stubbed(:task)
        assign(:task, @task)
        assign(:view, status)
        assign(:empty_bucket, :due_asap)
        assign(:task_total, stub_task_total(status))
      end

      it "should blind up out destroyed task partial" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

        render
        expect(rendered).to include("slideUp")
        expect(rendered).to include("$('#list_due_asap').fadeOut")
      end

      it "should update tasks sidebar" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

        render
        expect(rendered).to include("$('#sidebar').html")
        expect(rendered).to have_text("Recent Items")
        expect(rendered).to have_text("Completed")
      end
    end
  end

  describe "destroy from related asset" do
    it "should blind up out destroyed task partial" do
      @task = build_stubbed(:task)
      assign(:task, @task)
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"

      render
      expect(rendered).to include("slideUp")
      expect(rendered).not_to include("fadeOut") # bucket is not empty
    end
  end
end
