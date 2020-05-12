# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe TasksHelper do
    describe "responding with generated links" do
      before do
        controller.extend ::FatFreeCrm::Engine.routes.url_helpers
        @task = create(:task)
      end

      it "should render link to uncomplete of a task" do
        expect(link_to_task_uncomplete(@task, nil)).to include(t(:task_uncomplete))
      end
    end
  end
end
