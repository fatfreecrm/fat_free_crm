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
# Table name: leads
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  campaign_id     :integer
#  assigned_to     :integer
#  first_name      :string(64)      default(""), not null
#  last_name       :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  title           :string(64)
#  company         :string(64)
#  source          :string(32)
#  status          :string(32)
#  referred_by     :string(64)
#  email           :string(64)
#  alt_email       :string(64)
#  phone           :string(32)
#  mobile          :string(32)
#  blog            :string(128)
#  linkedin        :string(128)
#  facebook        :string(128)
#  twitter         :string(128)
#  rating          :integer         default(0), not null
#  do_not_call     :boolean         default(FALSE), not null
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#  skype           :string(128)
#

class Lead < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :campaign
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_one     :contact, :dependent => :nullify # On destroy keep the contact, but nullify its lead_id
  has_many    :tasks, :as => :asset, :dependent => :destroy#, :order => 'created_at DESC'
  has_one     :business_address, :dependent => :destroy, :as => :addressable, :class_name => "Address", :conditions => "address_type='Business'"
  has_many    :emails, :as => :mediator
  has_many    :subscriptions, :as => :entity, :dependent => :destroy
  
  accepts_nested_attributes_for :business_address, :allow_destroy => true

  scope :state, lambda { |filters|
    where([ 'status IN (?)' + (filters.delete('other') ? ' OR status IS NULL' : ''), filters ])
  }
  scope :converted, where(:status => 'converted')
  scope :for_campaign, lambda { |id| where('campaign_id = ?', id) }
  scope :created_by, lambda { |user| where('user_id = ?' , user.id) }
  scope :assigned_to, lambda { |user| where('assigned_to = ?' , user.id) }

  scope :text_search, lambda { |query|
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    where('upper(first_name) LIKE upper(:s) OR upper(last_name) LIKE upper(:s) OR upper(company) LIKE upper(:m) OR upper(email) LIKE upper(:m)', :s => "#{query}%", :m => "%#{query}%")
  }

  uses_user_permissions
  acts_as_commentable
  acts_as_taggable_on :tags
  has_paper_trail
  has_fields
  exportable
  sortable :by => [ "first_name ASC", "last_name ASC", "company ASC", "rating DESC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  validates_presence_of :first_name, :message => :missing_first_name
  validates_presence_of :last_name, :message => :missing_last_name if Setting.require_last_names
  validate :users_for_shared_access

  after_create  :increment_leads_count
  after_destroy :decrement_leads_count

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20                  ; end
  def self.outline  ; "long"              ; end
  def self.first_name_position ; "before" ; end

  # Save the lead along with its permissions.
  #----------------------------------------------------------------------------
  def save_with_permissions(params)
    self.campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
    if self.access == "Campaign" && self.campaign # Copy campaign permissions.
      save_with_model_permissions(Campaign.find(self.campaign_id))
    else
      super(params[:users]) # invoke :save_with_permissions in plugin.
    end
  end

  # Update lead attributes taking care of campaign lead counters when necessary.
  #----------------------------------------------------------------------------
  def update_with_permissions(attributes, users)
    if self.campaign_id == attributes[:campaign_id] # Same campaign (if any).
      super(attributes, users)                      # See lib/fat_free_crm/permissions.rb
    else                                            # Campaign has been changed -- update lead counters...
      decrement_leads_count                         # ..for the old campaign...
      lead = super(attributes, users)               # Assign new campaign.
      increment_leads_count                         # ...and now for the new campaign.
      lead
    end
  end

  # Promote the lead by creating contact and optional opportunity. Upon
  # successful promotion Lead status gets set to :converted.
  #----------------------------------------------------------------------------
  def promote(params)
    account     = Account.create_or_select_for(self, params[:account], params[:users])
    opportunity = Opportunity.create_for(self, account, params[:opportunity], params[:users])
    contact     = Contact.create_for(self, account, opportunity, params)

    return account, opportunity, contact
  end

  #----------------------------------------------------------------------------
  def convert
    update_attribute(:status, "converted")
  end

  #----------------------------------------------------------------------------
  def reject
    update_attribute(:status, "rejected")
  end

  # Attach a task to the lead if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(task)
    unless self.task_ids.include?(task.id)
      self.tasks << task
    end
  end

  # Discard a task from the lead.
  #----------------------------------------------------------------------------
  def discard!(task)
    task.update_attribute(:asset, nil)
  end

  #----------------------------------------------------------------------------
  def full_name(format = nil)
    if format.nil? || format == "before"
      "#{self.first_name} #{self.last_name}"
    else
      "#{self.last_name}, #{self.first_name}"
    end
  end
  alias :name :full_name

  private
  #----------------------------------------------------------------------------
  def increment_leads_count
    if self.campaign_id
      Campaign.increment_counter(:leads_count, self.campaign_id)
    end
  end

  #----------------------------------------------------------------------------
  def decrement_leads_count
    if self.campaign_id
      Campaign.decrement_counter(:leads_count, self.campaign_id)
    end
  end

  # Make sure at least one user has been selected if the lead is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_lead) if self[:access] == "Shared" && !self.permissions.any?
  end

end

