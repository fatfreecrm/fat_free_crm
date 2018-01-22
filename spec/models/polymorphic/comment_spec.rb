# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: comments
#
#  id               :integer         not null, primary key
#  user_id          :integer
#  commentable_id   :integer
#  commentable_type :string(255)
#  private          :boolean
#  title            :string(255)     default("")
#  comment          :text
#  created_at       :datetime
#  updated_at       :datetime
#  state            :string(16)      default("Expanded"), not null
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Comment do
  it "should create a new instance given valid attributes" do
    Comment.create!(comment: "Hello", user: create(:user), commentable: create(:lead))
  end

  it "should subscribe users mentioned in the comment to the entity, and notify them via email" do
    expected_users = [
      create(:user, username: "test_user"),
      create(:user, username: "another_user")
    ]
    entity = create(:lead)
    Comment.create!(comment: "Hey @test_user, take a look at this. Also show @another_user",
                    user: create(:user),
                    commentable: entity)

    expected_users.each do |user|
      expect(entity.subscribed_users).to include(user.id)
    end
  end
end
