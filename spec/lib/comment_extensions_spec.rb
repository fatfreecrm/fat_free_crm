# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe FatFreeCrm::CommentExtensions do
  describe "add_comment_by_user" do
    let(:user) { create(:user) }

    before do
      ActiveRecord::Base.connection.create_table(:fat_free_crm_commentable_entities) do |t|
        t.string :subscribed_users
      end

      module FatFreeCrm
        class CommentableEntity < ActiveRecord::Base
          serialize :subscribed_users, Set
          acts_as_commentable
          uses_comment_extensions
        end
      end
    end

    after do
      ActiveRecord::Base.connection.drop_table(:fat_free_crm_commentable_entities)
    end

    it "should create a comment for user" do
      entity = FatFreeCrm::CommentableEntity.create
      entity.add_comment_by_user("I will handle this one", user)
      expect(entity.reload.comments.map(&:comment)).to include("I will handle this one")
    end

    it "should not create a comment if body is blank" do
      entity = FatFreeCrm::CommentableEntity.create
      entity.add_comment_by_user("", user)
      expect(entity.reload.comments).to be_empty
    end
  end
end
