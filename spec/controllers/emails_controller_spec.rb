# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe EmailsController, "handling GET /emails" do
  MEDIATOR = [ :account, :campaign, :contact, :lead, :opportunity ].freeze

  before(:each) do
    require_user
  end

  # DELETE /emails/1
  # DELETE /emails/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    describe "AJAX request" do
      describe "with valid params" do
        MEDIATOR.each do |asset|
          it "should destroy the requested email and render [destroy] template" do
            @asset = create(asset)
            @email = create(:email, mediator: @asset, user: current_user)
            Email.stub(:new).and_return(@email)

            xhr :delete, :destroy, id: @email.id
            lambda { Email.find(@email) }.should raise_error(ActiveRecord::RecordNotFound)
            response.should render_template("emails/destroy")
          end
        end
      end
    end
  end

end
