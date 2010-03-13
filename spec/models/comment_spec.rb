# == Schema Information
# Schema version: 27
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  user_id          :integer(4)
#  commentable_id   :integer(4)
#  commentable_type :string(255)
#  private          :boolean(1)
#  title            :string(255)     default("")
#  comment          :text
#  created_at       :datetime
#  updated_at       :datetime
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Comment do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Comment.create!(:comment => "Hello", :user => Factory(:user), :commentable => Factory(:lead))
  end
end
