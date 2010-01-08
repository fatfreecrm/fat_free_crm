# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

# == Schema Information
# Schema version: 23
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
  named_scope :for,    lambda { |user|     { :conditions => [ "user_id =?", user.id] } }
  named_scope :only,   lambda { |*actions| { :conditions => "action     IN (#{actions.join("','").wrap("'")})" } }
  named_scope :except, lambda { |*actions| { :conditions => "action NOT IN (#{actions.join("','").wrap("'")})" } }
  named_scope :latest, lambda { |options|  {
    :conditions => [ "#{options[:asset] ? "subject_type = ?" : "0=?"} AND #{options[:user] ? "user_id = ?" : "0=?"} AND activities.created_at >= ?",
      options[:asset] || 0, options[:user] || 0, Time.zone.now - (options[:duration] || 2.days) ],
    :include => :user,
    :order => "activities.created_at DESC"
  } }

  validates_presence_of :user, :subject

  ASSETS = %w(all tasks campaigns leads accounts contacts opportunities).inject([]) { |arr, asset| arr << [ asset, I18n.t(asset) ] }
  DURATION = %w(one_hour one_day two_days one_week two_weeks one_month).inject([]) { |arr, duration| arr << [ duration, I18n.t(duration) ] }

  #----------------------------------------------------------------------------
  def self.log(user, subject, action)
    if action != :viewed
      create_activity(user, subject, action)
      if action == :created
        create_activity(user, subject, :viewed)
      elsif action == :deleted
         # Remove the subject from recently viewed list. Note that we don't
         # specify an user since we want to delete :viewed activity for all users.
        delete_activity(nil, subject, :viewed)
      end
    end
    if [:viewed, :updated, :commented].include?(action)
      update_activity(user, subject, :viewed)
    end
  end

  private
  #----------------------------------------------------------------------------
  def self.create_activity(user, subject, action)
    unless subject.is_a?(Task) && action == :viewed # Tasks don't have landing pages, so technically they can't be "viewed".
      create(
        :user    => user,
        :subject => subject,
        :action  => action.to_s,
        :info    => subject.respond_to?(:full_name) ? subject.full_name : subject.name
      )
    end
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
    unless user
      delete_all([ "subject_id=? AND subject_type=? AND action=?", subject.id, subject.class.name, action.to_s ])
    else
      delete_all([ "user_id=? AND subject_id=? AND subject_type=? AND action=?", user.id, subject.id, subject.class.name, action.to_s ])
    end
  end

end
