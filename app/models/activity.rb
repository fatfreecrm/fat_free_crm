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
  named_scope :recent, { :conditions => "action='viewed'", :order => "updated_at DESC", :limit => 10 }
  named_scope :latest, lambda { { :conditions => [ "activities.created_at >= ?", Date.today - 1.week ], :include => :user, :order => "activities.created_at DESC" } }
  named_scope :for,    lambda { |user| { :conditions => [ "user_id =?", user.id] } }
  named_scope :only,   lambda { |*actions| { :conditions => "action     IN (#{actions.join("','").wrap("'")})" } }
  named_scope :except, lambda { |*actions| { :conditions => "action NOT IN (#{actions.join("','").wrap("'")})" } }

  validates_presence_of :user, :subject

  #----------------------------------------------------------------------------
  def self.stamp(user, subject, action)
    if action != :viewed
      create_activity(user, subject, action)
      if action == :created
        create_activity(user, subject, :viewed)
      elsif action == :deleted
        delete_activity(user, subject, :viewed)
      end
    end
    if action == :viewed || action == :updated
      update_activity(user, subject, :viewed)
    end
  end

  private
  #----------------------------------------------------------------------------
  def self.create_activity(user, subject, action)
    create(
      :user    => user,
      :subject => subject,
      :action  => action.to_s,
      :info    => subject.respond_to?(:full_name) ? subject.full_name : subject.name
    )
  end

  #----------------------------------------------------------------------------
  def self.update_activity(user, subject, action)
    activity = Activity.first(:conditions => [ "user_id=? AND subject_id=? AND subject_type=? AND action=?", user.id, subject.id, subject.class.name, action.to_s ])
    if activity
      activity.update_attribute(:updated_at, Time.now)
    else
      create_activity(user, subject, action)
    end
  end

  #----------------------------------------------------------------------------
  def self.delete_activity(user, subject, action)
    delete_all([ "user_id=? AND subject_id=? AND subject_type=? AND action=?", user.id, subject.id, subject.class.name, action.to_s ])
  end

end
