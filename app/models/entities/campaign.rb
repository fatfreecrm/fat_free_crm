# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
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
#
# Table name: campaigns
#
#  id                  :integer         not null, primary key
#  user_id             :integer
#  assigned_to         :integer
#  name                :string(64)      default(""), not null
#  access              :string(8)       default("Public")
#  status              :string(64)
#  budget              :decimal(12, 2)
#  target_leads        :integer
#  target_conversion   :float
#  target_revenue      :decimal(12, 2)
#  leads_count         :integer
#  opportunities_count :integer
#  revenue             :decimal(12, 2)
#  starts_on           :date
#  ends_on             :date
#  objectives          :text
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  background_info     :string(255)
#

class Campaign < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many    :tasks, :as => :asset, :dependent => :destroy#, :order => 'created_at DESC'
  has_many    :leads, :dependent => :destroy, :order => "id DESC"
  has_many    :opportunities, :dependent => :destroy, :order => "id DESC"
  has_many    :emails, :as => :mediator

  serialize :subscribed_users, Array

  scope :state, lambda { |filters|
    where('status IN (?)' + (filters.delete('other') ? ' OR status IS NULL' : ''), filters)
  }
  scope :created_by, lambda { |user| where('user_id = ?' , user.id) }
  scope :assigned_to, lambda { |user| where('assigned_to = ?', user.id) }

  scope :text_search, lambda { |query|
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    where('upper(name) LIKE upper(?)', "%#{query}%")
  }

  uses_user_permissions
  acts_as_commentable
  acts_as_taggable_on :tags
  has_paper_trail
  has_fields
  exportable
  sortable :by => [ "name ASC", "target_leads DESC", "target_revenue DESC", "leads_count DESC", "revenue DESC", "starts_on DESC", "ends_on DESC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  validates_presence_of :name, :message => :missing_campaign_name
  validates_uniqueness_of :name, :scope => [ :user_id, :deleted_at ]
  validate :start_and_end_dates
  validate :users_for_shared_access

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20     ; end
  def self.outline  ; "long" ; end

  # Attach given attachment to the campaign if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    unless self.send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      if attachment.is_a?(Task)
        self.send(attachment.class.name.tableize) << attachment
      else # Leads, Opportunities
        attachment.update_attribute(:campaign, self)
        attachment.send("increment_#{attachment.class.name.tableize}_count")
        [ attachment ]
      end
    end
  end

  # Discard given attachment from the campaign.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Leads, Opportunities
      attachment.send("decrement_#{attachment.class.name.tableize}_count")
      attachment.update_attribute(:campaign, nil)
    end
  end

  private
  # Make sure end date > start date.
  #----------------------------------------------------------------------------
  def start_and_end_dates
    if (self.starts_on && self.ends_on) && (self.starts_on > self.ends_on)
      errors.add(:ends_on, :dates_not_in_sequence)
    end
  end

  # Make sure at least one user has been selected if the campaign is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_campaign) if self[:access] == "Shared" && !self.permissions.any?
  end

end

