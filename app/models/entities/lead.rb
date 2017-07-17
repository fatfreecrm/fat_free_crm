# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
  belongs_to :user
  belongs_to :campaign
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  has_one :contact, dependent: :nullify # On destroy keep the contact, but nullify its lead_id
  has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'
  has_one :business_address, -> { where "address_type='Business'" }, dependent: :destroy, as: :addressable, class_name: "Address"
  has_many :addresses, dependent: :destroy, as: :addressable, class_name: "Address" # advanced search uses this
  has_many :emails, as: :mediator

  serialize :subscribed_users, Set

  accepts_nested_attributes_for :business_address, allow_destroy: true

  scope :state, ->(filters) {
    where(['status IN (?)' + (filters.delete('other') ? ' OR status IS NULL' : ''), filters])
  }
  scope :converted,    ->       { where(status: 'converted') }
  scope :for_campaign, ->(id)   { where(campaign_id: id) }
  scope :created_by,   ->(user) { where(user_id: user.id) }
  scope :assigned_to,  ->(user) { where(assigned_to: user.id) }

  scope :text_search, ->(query) { ransack('first_name_or_last_name_or_company_or_email_cont' => query).result }

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail class_name: 'Version', ignore: [:subscribed_users]
  has_fields
  exportable
  sortable by: ["first_name ASC", "last_name ASC", "company ASC", "rating DESC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w(contact campaign tasks tags activities emails addresses comments)
  ransack_can_autocomplete

  validates_presence_of :first_name, message: :missing_first_name, if: -> { Setting.require_first_names }
  validates_presence_of :last_name,  message: :missing_last_name,  if: -> { Setting.require_last_names  }
  validate :users_for_shared_access
  validates :status, inclusion: { in: proc { Setting.unroll(:lead_status).map { |s| s.last.to_s } } }, allow_blank: true

  after_create :increment_leads_count
  after_destroy :decrement_leads_count

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page
    20
  end

  def self.first_name_position
    "before"
  end

  # Save the lead along with its permissions.
  #----------------------------------------------------------------------------
  def save_with_permissions(params)
    self.campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
    if params[:lead][:access] == "Campaign" && campaign # Copy campaign permissions.
      save_with_model_permissions(Campaign.find(campaign_id))
    else
      self.attributes = params[:lead]
      save
    end
  end

  # Deprecated: see update_with_lead_counters
  #----------------------------------------------------------------------------
  def update_with_permissions(attributes, _users = nil)
    ActiveSupport::Deprecation.warn "lead.update_with_permissions is deprecated and may be removed from future releases, use user_ids and group_ids inside attributes instead and call lead.update_with_lead_counters"
    update_with_lead_counters(attributes)
  end

  # Update lead attributes taking care of campaign lead counters when necessary.
  #----------------------------------------------------------------------------
  def update_with_lead_counters(attributes)
    if campaign_id == attributes[:campaign_id] # Same campaign (if any).
      self.attributes = attributes
      save
    else                                            # Campaign has been changed -- update lead counters...
      decrement_leads_count                         # ..for the old campaign...
      self.attributes = attributes                  # Assign new campaign.
      lead = save
      increment_leads_count                         # ...and now for the new campaign.
      lead
    end
  end

  # Promote the lead by creating contact and optional opportunity. Upon
  # successful promotion Lead status gets set to :converted.
  #----------------------------------------------------------------------------
  def promote(params)
    account_params = params[:account] ? params[:account] : {}
    opportunity_params = params[:opportunity] ? params[:opportunity] : {}

    account     = Account.create_or_select_for(self, account_params)
    opportunity = Opportunity.create_for(self, account, opportunity_params)
    contact     = Contact.create_for(self, account, opportunity, params)

    [account, opportunity, contact]
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
    tasks << task unless task_ids.include?(task.id)
  end

  # Discard a task from the lead.
  #----------------------------------------------------------------------------
  def discard!(task)
    task.update_attribute(:asset, nil)
  end

  #----------------------------------------------------------------------------
  def full_name(format = nil)
    if format.nil? || format == "before"
      "#{first_name} #{last_name}"
    else
      "#{last_name}, #{first_name}"
    end
  end
  alias_method :name, :full_name

  private

  #----------------------------------------------------------------------------
  def increment_leads_count
    Campaign.increment_counter(:leads_count, campaign_id) if campaign_id
  end

  #----------------------------------------------------------------------------
  def decrement_leads_count
    Campaign.decrement_counter(:leads_count, campaign_id) if campaign_id
  end

  # Make sure at least one user has been selected if the lead is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_lead) if self[:access] == "Shared" && !permissions.any?
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_lead, self)
end
