# frozen_string_literal: true

# == Schema Information
#
# Table name: bundles
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  name            :string(128)     not null
#  qr_code         :string(255)     not null
#  description     :string
#  location        :string(128)
#  access          :string(8)       default("Public")
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class Bundle < ActiveRecord::Base
  belongs_to :user, optional: true
  has_many :samples, dependent: :nullify
  has_many :tasks, as: :asset, dependent: :destroy

  serialize :subscribed_users, type: Array

  scope :state, lambda { |filters|
    where('location IN (?)' + (filters.delete('other') ? ' OR location IS NULL' : ''), filters)
  }
  scope :created_by, ->(user) { where(user_id: user.id) }
  scope :by_location, ->(location) { where(location: location) }

  scope :text_search, ->(query) { ransack('name_or_qr_code_or_description_cont' => query).result }

  scope :visible_on_dashboard, lambda { |user|
    where('user_id = :user_id', user_id: user.id)
  }

  scope :by_name, -> { order(:name) }

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail versions: { class_name: 'Version' }, ignore: [:subscribed_users]
  has_fields
  exportable
  sortable by: ["name ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w[samples tags activities comments tasks]
  ransack_can_autocomplete

  validates_presence_of :name, message: :missing_bundle_name
  validates_presence_of :qr_code, message: :missing_bundle_qr_code
  validates_uniqueness_of :name, scope: :deleted_at
  validates_uniqueness_of :qr_code, scope: :deleted_at
  validate :users_for_shared_access

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page
    20
  end

  def self.sort_by
    "bundles.created_at DESC"
  end

  # Get total value of samples in bundle
  #----------------------------------------------------------------------------
  def total_value
    samples.sum(:best_price)
  end

  # Get count of available samples
  #----------------------------------------------------------------------------
  def available_samples_count
    samples.available.count
  end

  # Get count of fire sale samples
  #----------------------------------------------------------------------------
  def fire_sale_samples_count
    samples.fire_sale.count
  end

  private

  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_bundle) if self[:access] == "Shared" && permissions.none?
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_bundle, self)
end
