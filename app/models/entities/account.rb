# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: accounts
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  assigned_to     :integer
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  website         :string(64)
#  toll_free_phone :string(32)
#  phone           :string(32)
#  fax             :string(32)
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  email           :string(64)
#  background_info :string(255)
#  rating          :integer         default(0), not null
#  category        :string(32)
#

class Account < ActiveRecord::Base
  belongs_to :user, optional: true # TODO: Is this really optional?
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to, optional: true
  has_many :account_contacts, dependent: :destroy
  has_many :contacts, -> { distinct }, through: :account_contacts
  has_many :account_opportunities, dependent: :destroy
  has_many :opportunities, -> { order("opportunities.id DESC").distinct }, through: :account_opportunities
  has_many :pipeline_opportunities, -> { order("opportunities.id DESC").distinct.pipeline }, through: :account_opportunities, source: :opportunity
  has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'
  has_one :billing_address, -> { where(address_type: "Billing") }, dependent: :destroy, as: :addressable, class_name: "Address"
  has_one :shipping_address, -> { where(address_type: "Shipping") }, dependent: :destroy, as: :addressable, class_name: "Address"
  has_many :addresses, dependent: :destroy, as: :addressable, class_name: "Address" # advanced search uses this
  has_many :emails, as: :mediator

  serialize :subscribed_users, Array

  accepts_nested_attributes_for :billing_address,  allow_destroy: true, reject_if: proc { |attributes| Address.reject_address(attributes) }
  accepts_nested_attributes_for :shipping_address, allow_destroy: true, reject_if: proc { |attributes| Address.reject_address(attributes) }

  scope :state, lambda { |filters|
    where('category IN (?)' + (filters.delete('other') ? ' OR category IS NULL' : ''), filters)
  }
  scope :created_by,  ->(user) { where(user_id: user.id) }
  scope :assigned_to, ->(user) { where(assigned_to: user.id) }

  scope :text_search, ->(query) { ransack('name_or_email_cont' => query).result }

  scope :visible_on_dashboard, lambda { |user|
    # Show accounts which either belong to the user and are unassigned, or are assigned to the user
    where('(user_id = :user_id AND assigned_to IS NULL) OR assigned_to = :user_id', user_id: user.id)
  }

  scope :by_name, -> { order(:name) }

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail versions: { class_name: 'Version' }, ignore: [:subscribed_users]
  has_fields
  exportable
  sortable by: ["name ASC", "rating DESC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w[contacts opportunities tags activities emails addresses comments tasks]
  ransack_can_autocomplete

  validates_presence_of :name, message: :missing_account_name
  validates_uniqueness_of :name, scope: :deleted_at, if: -> { Setting.require_unique_account_names }
  validates :rating, inclusion: { in: 0..5 }, allow_blank: true
  validates :category, inclusion: { in: proc { Setting.unroll(:account_category).map { |s| s.last.to_s } } }, allow_blank: true
  validate :users_for_shared_access

  before_save :nullify_blank_category

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page
    20
  end

  # Extract last line of billing address and get rid of numeric zipcode.
  #----------------------------------------------------------------------------
  def location
    return "" unless self[:billing_address]

    location = self[:billing_address].strip.split("\n").last
    location&.gsub(/(^|\s+)\d+(:?\s+|$)/, " ")&.strip
  end

  # Attach given attachment to the account if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    send(attachment.class.name.tableize) << attachment unless send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
  end

  # Discard given attachment from the account.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Contacts, Opportunities
      send(attachment.class.name.tableize).delete(attachment)
    end
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_or_select_for(model, params)
    # Attempt to find existing account
    return Account.find(params[:id]) if params[:id].present?

    if params[:name].present?
      account = Account.find_by(name: params[:name])
      return account if account
    end

    # Fallback to create new account
    params[:user] = model.user if model
    account = Account.new(params)
    if account.access != "Lead" || model.nil?
      account.save
    else
      account.save_with_model_permissions(model)
    end
    account
  end

  private

  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_account) if self[:access] == "Shared" && permissions.none?
  end

  def nullify_blank_category
    self.category = nil if category.blank?
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_account, self)
end
