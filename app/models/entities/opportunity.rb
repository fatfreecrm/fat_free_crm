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
# Table name: opportunities
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  campaign_id     :integer
#  assigned_to     :integer
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  source          :string(32)
#  stage           :string(32)
#  probability     :integer
#  amount          :decimal(12, 2)
#  discount        :decimal(12, 2)
#  closes_on       :date
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#

class Opportunity < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :campaign
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_one     :account_opportunity, :dependent => :destroy
  has_one     :account, :through => :account_opportunity
  has_many    :contact_opportunities, :dependent => :destroy
  has_many    :contacts, :through => :contact_opportunities, :uniq => true, :order => "contacts.id DESC"
  has_many    :tasks, :as => :asset, :dependent => :destroy#, :order => 'created_at DESC'
  has_many    :emails, :as => :mediator

  serialize :subscribed_users, Array

  scope :state, lambda { |filters|
    where('stage IN (?)' + (filters.delete('other') ? ' OR stage IS NULL' : ''), filters)
  }
  scope :created_by, lambda { |user| where('user_id = ?', user.id) }
  scope :assigned_to, lambda { |user| where('assigned_to = ?', user.id) }
  scope :won,      where("opportunities.stage = 'won'")
  scope :lost,     where("opportunities.stage = 'lost'")
  scope :pipeline, where("opportunities.stage IS NULL OR (opportunities.stage != 'won' AND opportunities.stage != 'lost')")

  # Search by name OR id
  scope :text_search, lambda { |query|
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    # postgresql does not like to compare string to integer field
    if query =~ /^\d+$/
      where('upper(name) LIKE upper(:name) OR opportunities.id = :id', :name => "%#{query}%", :id => query)
    else
      where('upper(name) LIKE upper(:name)', :name => "%#{query}%")
    end
  }

  uses_user_permissions
  acts_as_commentable
  acts_as_taggable_on :tags
  has_paper_trail
  has_fields
  exportable
  sortable :by => [ "name ASC", "amount DESC", "amount*probability DESC", "probability DESC", "closes_on ASC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  validates_presence_of :name, :message => :missing_opportunity_name
  validates_numericality_of [ :probability, :amount, :discount ], :allow_nil => true
  validate :users_for_shared_access

  # Validate presence of account_opportunity unless the opportunity is deleted [with has_paper_trail],
  # in which case the account_opportunity will still exist but will be in a deleted state.
  # validates :account_opportunity, :presence => true, :unless => Proc.new { |o| o.destroyed? }
  # TODO: Mike, what do you think about the above validation?

  after_create  :increment_opportunities_count
  after_destroy :decrement_opportunities_count

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20     ; end
  def self.outline  ; "long" ; end

  #----------------------------------------------------------------------------
  def weighted_amount
    ((amount || 0) - (discount || 0)) * (probability || 0) / 100.0
  end

  # Backend handler for [Create New Opportunity] form (see opportunity/create).
  #----------------------------------------------------------------------------
  def save_with_account_and_permissions(params)
    # Quick sanitization, makes sure Account will not search for blank id.
    params[:account].delete(:id) if params[:account][:id].blank?
    account = Account.create_or_select_for(self, params[:account], params[:users])
    self.account_opportunity = AccountOpportunity.new(:account => account, :opportunity => self) unless account.id.blank?
    self.account = account
    self.contacts << Contact.find(params[:contact]) unless params[:contact].blank?
    self.campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
    self.save_with_permissions(params[:users])
  end

  # Backend handler for [Update Opportunity] form (see opportunity/update).
  #----------------------------------------------------------------------------
  def update_with_account_and_permissions(params)
    if params[:account] && (params[:account][:id] == "" || params[:account][:name] == "")
      self.account = nil # Opportunity is not associated with the account anymore.
    elsif params[:account]
      account = Account.create_or_select_for(self, params[:account], params[:users])
      if self.account != account and account.id.present?
        self.account_opportunity = AccountOpportunity.new(:account => account, :opportunity => self)
      end
    end
    self.reload
    self.update_with_permissions(params[:opportunity], params[:users])
  end

  # Attach given attachment to the opportunity if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    unless self.send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      self.send(attachment.class.name.tableize) << attachment
    end
  end

  # Discard given attachment from the opportunity.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Contacts
      self.send(attachment.class.name.tableize).delete(attachment)
    end
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_for(model, account, params, users)
    opportunity = Opportunity.new(params)

    # Save the opportunity if its name was specified and account has no errors.
    if opportunity.name? && account.errors.empty?
      # Note: opportunity.account = account doesn't seem to work here.
      opportunity.account_opportunity = AccountOpportunity.new(:account => account, :opportunity => opportunity) unless account.id.blank?
      if opportunity.access != "Lead" || model.nil?
        opportunity.save_with_permissions(users)
      else
        opportunity.save_with_model_permissions(model)
      end
    end
    opportunity
  end

  private
  # Make sure at least one user has been selected if the contact is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_opportunity) if self[:access] == "Shared" && !self.permissions.any?
  end

  #----------------------------------------------------------------------------
  def increment_opportunities_count
    if self.campaign_id
      Campaign.increment_counter(:opportunities_count, self.campaign_id)
    end
  end

  #----------------------------------------------------------------------------
  def decrement_opportunities_count
    if self.campaign_id
      Campaign.decrement_counter(:opportunities_count, self.campaign_id)
    end
  end

end

