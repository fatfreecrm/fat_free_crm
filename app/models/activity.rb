class Activity < ActiveRecord::Base

  belongs_to  :user
  belongs_to  :subject, :polymorphic => true
  named_scope :latest, lambda { { :conditions => [ "activities.created_at >= ?", Date.today - 1.week ], :include => :user, :order => "activities.created_at DESC" } }

  validates_presence_of :user, :subject
end
