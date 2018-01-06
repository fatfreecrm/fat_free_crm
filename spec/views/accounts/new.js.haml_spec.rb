# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/new" do
  include AccountsHelper

  before do
    login
    assign(:account, Account.new(user: current_user))
    assign(:users, [current_user])
  end

  it "should toggle empty message div if it exists" do
    render

    expect(rendered).to include("crm.flick('empty', 'toggle')")
  end

  describe "new account" do
    it "should render [new] template into :create_account div" do
      params[:cancel] = nil
      render

      expect(rendered).to include("#create_account")
      expect(rendered).to include("crm.flip_form('create_account');")
    end
  end

  describe "cancel new account" do
    it "should hide [create account] form()" do
      params[:cancel] = "true"
      render

      expect(rendered).not_to include("#create_account")
      expect(rendered).to include("crm.flip_form('create_account');")
    end
  end
end
