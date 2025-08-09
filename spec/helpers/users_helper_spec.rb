# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersHelper do
  let(:myself) { create(:user, id: 54) }
  let(:user1) { create(:user,  id: 60, first_name: 'Bob', last_name: "Hope") }
  let(:user2) { create(:user,  id: 75, first_name: 'Billy', last_name: "Joel") }

  describe "user_options_for_select" do
    it "includes 'myself'" do
      expect(user_options_for_select([user1, user2], myself)).to include(["Myself", 54])
    end

    it "includes other users" do
      expect(user_options_for_select([user1, user2], myself)).to include(["Bob Hope", 60], ["Billy Joel", 75])
    end
  end

  describe "user_select" do
    it "includes blank option" do
      expect(user_select(:lead, [user1, user2], myself)).to match(%r{<option value="">Unassigned</option>})
    end

    it "includes myself" do
      expect(user_select(:lead, [user1, user2], myself)).to match(%r{<option value="54">Myself</option>})
    end

    it "includes other users" do
      expect(user_select(:lead, [user1, user2], myself)).to match(%r{<option value="60">Bob Hope</option>})
      expect(user_select(:lead, [user1, user2], myself)).to match(%r{<option value="75">Billy Joel</option>})
    end
  end
end
