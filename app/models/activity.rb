# == Schema Information
# Schema version: 17
#
# Table name: activities
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)
#  subject_id   :integer(4)
#  subject_type :string(255)
#  action       :string(32)      default("created")
#  info         :string(255)     default("")
#  private      :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#

class Activity < ActiveRecord::Base

  belongs_to  :user
  belongs_to  :subject, :polymorphic => true
  named_scope :latest, lambda { { :conditions => [ "activities.created_at >= ?", Date.today - 1.week ], :include => :user, :order => "activities.created_at DESC" } }

  validates_presence_of :user, :subject
end
