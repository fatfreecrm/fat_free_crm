# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/tasks/_edit" do
  include TasksHelper

  before do
    login
    assign(:task, build_stubbed(:task, asset: build_stubbed(:account), bucket: "due_asap"))
    assign(:users, [current_user])
    assign(:bucket, %w[due_asap due_today])
    assign(:category, %w[meeting money])
  end

  it "should render [edit task] form" do
    render

    expect(view).to render_template(partial: "tasks/_top_section")

    expect(rendered).to have_tag('form[class="simple_form edit_task"]')
  end

  ["As Soon As Possible", "Today", "Tomorrow", "This Week", "Next Week", "Sometime Later"].each do |day|
    it "should render move to [#{day}] link" do
      render

      expect(rendered).to have_tag("a[onclick^='crm.reschedule']", text: day)
    end
  end

  it "should render background info if Settings request so" do
    Setting.background_info = [:task]
    render

    expect(rendered).to have_tag("textarea[id=task_background_info]")
  end

  it "should not render background info if Settings do not request so" do
    Setting.background_info = []
    render

    expect(rendered).not_to have_tag("textarea[id=task_background_info]")
  end
end
