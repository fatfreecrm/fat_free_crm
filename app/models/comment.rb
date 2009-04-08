# == Schema Information
# Schema version: 17
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

class Comment < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :commentable, :polymorphic => true
  has_many    :activities, :as => :subject, :order => 'created_at DESC'

  validates_presence_of :user_id, :commentable_id, :commentable_type, :comment

  # Activity observer expects model to respond to :name or :full_name.
  #----------------------------------------------------------------------------
  def name
    comment.shorten(80)
  end

end
