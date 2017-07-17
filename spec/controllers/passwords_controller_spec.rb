# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe PasswordsController do
  let(:user) { FactoryGirl.build(:user) }

  describe "update" do
    before(:each) do
      allow(User).to receive(:find_using_perishable_token).and_return(user)
    end

    it "should accept non-blank passwords" do
      password = "password"
      expect(user).to receive(:update_attributes).and_return(true)
      put :update, params: { id: 1, user: { password: password, password_confirmation: password } }
      expect(response).to redirect_to(profile_url)
    end

    it "should not accept blank passwords" do
      password = "    "
      expect(user).not_to receive(:update_attributes)
      put :update, params: { id: 1, user: { password: password, password_confirmation: password } }
      expect(response).to render_template('edit')
    end
  end
end
