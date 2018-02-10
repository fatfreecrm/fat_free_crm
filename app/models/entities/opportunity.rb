# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
  belongs_to :user
  belongs_to :campaign
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  has_one :account_opportunity, dependent: :destroy
  has_one :account, through: :account_opportunity
  has_many :contact_opportunities, dependent: :destroy
  has_many :contacts, -> { order("contacts.id DESC").distinct }, through: :contact_opportunities
  has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'
  has_many :emails, as: :mediator

  serialize :subscribed_users, Set

  scope :state, ->(filters) {
    where('stage IN (?)' + (filters.delete('other') ? ' OR stage IS NULL' : ''), filters)
  }
  scope :created_by,  ->(user) { where('user_id = ?', user.id) }
  scope :assigned_to, ->(user) { where('assigned_to = ?', user.id) }
  scope :won,         -> { where("opportunities.stage = 'won'") }
  scope :lost,        -> { where("opportunities.stage = 'lost'") }
  scope :not_lost,    -> { where("opportunities.stage <> 'lost'") }
  scope :pipeline,    -> { where("opportunities.stage IS NULL OR (opportunities.stage != 'won' AND opportunities.stage != 'lost')") }
  scope :unassigned,  -> { where("opportunities.assigned_to IS NULL") }
  scope :weighted_sort, -> { select('*, amount*probability') }

  # Search by name OR id
  scope :text_search, ->(query) {
    if query.match?(/\A\d+\z/)
      where('upper(name) LIKE upper(:name) OR opportunities.id = :id', name: "%#{query}%", id: query)
    else
      ransack('name_cont' => query).result
    end
  }

  scope :visible_on_dashboard, ->(user) {
    # Show opportunities which either belong to the user and are unassigned, or are assigned to the user and haven't been closed (won/lost)
    where('(user_id = :user_id AND assigned_to IS NULL) OR assigned_to = :user_id', user_id: user.id).where("opportunities.stage != 'won'").where("opportunities.stage != 'lost'")
  }

  scope :by_closes_on, -> { order(:closes_on) }
  scope :by_amount,    -> { order('opportunities.amount DESC') }

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail class_name: 'Version', ignore: [:subscribed_users]
  has_fields
  exportable
  sortable by: ["name ASC", "amount DESC", "amount*probability DESC", "probability DESC", "closes_on ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w[account contacts tags campaign activities emails comments]
  ransack_can_autocomplete

  validates_presence_of :name, message: :missing_opportunity_name
  validates_numericality_of %i[probability amount discount], allow_nil: true
  validate :users_for_shared_access
  validates :stage, inclusion: { in: proc { Setting.unroll(:opportunity_stage).map { |s| s.last.to_s } } }, allow_blank: true

  after_create :increment_opportunities_count
  after_destroy :decrement_opportunities_count

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page
    20
  end

  def self.default_stage
    Setting[:opportunity_default_stage].try(:to_s) || 'prospecting'
  end

  #----------------------------------------------------------------------------
  def weighted_amount
    (amount.to_f - discount.to_f) * probability.to_i / 100.0
  end

  # Backend handler for [Create New Opportunity] form (see opportunity/create).
  #----------------------------------------------------------------------------
  def save_with_account_and_permissions(params)
    # Quick sanitization, makes sure Account will not search for blank id.
    params[:account].delete(:id) if params[:account][:id].blank?
    account = Account.create_or_select_for(self, params[:account])
    self.account_opportunity = AccountOpportunity.new(account: account, opportunity: self) unless account.id.blank?
    self.account = account
    self.campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
    result = save
    contacts << Contact.find(params[:contact]) unless params[:contact].blank?
    result
  end

  # Backend handler for [Update Opportunity] form (see opportunity/update).
  #----------------------------------------------------------------------------
  def update_with_account_and_permissions(params)
    if params[:account] && (params[:account][:id] == "" || params[:account][:name] == "")
      self.account = nil # Opportunity is not associated with the account anymore.
    elsif params[:account]
      self.account = Account.create_or_select_for(self, params[:account])
    end
    # Must set access before user_ids, because user_ids= method depends on access value.
    self.access = params[:opportunity][:access] if params[:opportunity][:access]
    self.attributes = params[:opportunity]
    save
  end

  # Attach given attachment to the opportunity if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    unless send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      send(attachment.class.name.tableize) << attachment
    end
  end

  # Discard given attachment from the opportunity.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Contacts
      send(attachment.class.name.tableize).delete(attachment)
    end
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_for(model, account, params)
    opportunity = Opportunity.new(params)

    # Save the opportunity if its name was specified and account has no errors.
    if opportunity.name? && account.errors.empty?
      # Note: opportunity.account = account doesn't seem to work here.
      opportunity.account_opportunity = AccountOpportunity.new(account: account, opportunity: opportunity) unless account.id.blank?
      if opportunity.access != "Lead" || model.nil?
        opportunity.save
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
    errors.add(:access, :share_opportunity) if self[:access] == "Shared" && permissions.none?
  end

  #----------------------------------------------------------------------------
  def increment_opportunities_count
    Campaign.increment_counter(:opportunities_count, campaign_id) if campaign_id
  end

  #----------------------------------------------------------------------------
  def decrement_opportunities_count
    Campaign.decrement_counter(:opportunities_count, campaign_id) if campaign_id
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_opportunity, self)
end
