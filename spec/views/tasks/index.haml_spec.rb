# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/index" do
  include TasksHelper

  before do
    login
  end

  TASK_STATUSES.each do |status|
    before do
      user = build_stubbed(:user)
      account = build_stubbed(:account)
      @due = build_stubbed(:task, asset: account, bucket: "due_asap", assignee: user)
      @completed = build_stubbed(:task, asset: account, bucket: "completed_today", assignee: user, completed_at: 1.hour.ago, completor: user)
    end

    it "should render list of #{status} tasks if list of tasks is not empty" do
      assign(:view, status)
      assign(:tasks, due_asap: [@due], completed_today: [@completed])

      render

      expect(view).to render_template(partial: "_#{status}", count: 1)
      expect(view).not_to render_template(partial: "_empty")
    end
  end

  TASK_STATUSES.each do |status|
    it "should render a message if there're no #{status} tasks" do
      assign(:view, status)
      assign(:tasks, due_asap: [], due_today: [])

      render

      expect(view).to render_template(partial: "_empty")
    end
  end
end
