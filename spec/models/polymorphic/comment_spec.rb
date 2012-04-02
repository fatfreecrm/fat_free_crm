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

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Comment.create!(:comment => "Hello", :user => FactoryGirl.create(:user), :commentable => FactoryGirl.create(:lead))
  end
end

