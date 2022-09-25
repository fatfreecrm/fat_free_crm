# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FatFreeCRM::CommentExtensions do
  describe "add_comment_by_user" do
    let(:user) { create(:user) }

    before do
      ActiveRecord::Base.connection.create_table(:commentable_entities) do |t|
        t.string :subscribed_users
      end

      class CommentableEntity < ActiveRecord::Base
        serialize :subscribed_users, Array
        acts_as_commentable
        uses_comment_extensions
      end
    end

    after do
      ActiveRecord::Base.connection.drop_table(:commentable_entities)
    end

    it "should create a comment for user" do
      entity = CommentableEntity.create
      entity.add_comment_by_user("I will handle this one", user)
      expect(entity.reload.comments.map(&:comment)).to include("I will handle this one")
    end

    it "should not create a comment if body is blank" do
      entity = CommentableEntity.create
      entity.add_comment_by_user("", user)
      expect(entity.reload.comments).to be_empty
    end
  end
end
