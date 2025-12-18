# frozen_string_literal: true

# == Schema Information
#
# Table name: samples
#
#  id                   :integer         not null, primary key
#  user_id              :integer
#  bundle_id            :integer
#  name                 :string(128)     not null
#  brand                :string(128)
#  location             :string(128)
#  qr_code              :string(255)
#  sku                  :string(64)
#  tiktok_affiliate_link :string(512)
#  has_fire_sale        :boolean         default(false), not null
#  best_price           :decimal(10,2)
#  original_price       :decimal(10,2)
#  status               :string(32)      default("available")
#  access               :string(8)       default("Public")
#  description          :text
#  notes                :text
#  checked_out_at       :datetime
#  checked_out_by       :integer
#  deleted_at           :datetime
#  created_at           :datetime
#  updated_at           :datetime
#

class Sample < ActiveRecord::Base
  belongs_to :user, optional: true
  belongs_to :bundle, optional: true, counter_cache: true
  belongs_to :checked_out_user, class_name: "User", foreign_key: :checked_out_by, optional: true
  has_many :tasks, as: :asset, dependent: :destroy

  has_one_attached :picture

  serialize :subscribed_users, type: Array

  scope :state, lambda { |filters|
    where('status IN (?)' + (filters.delete('other') ? ' OR status IS NULL' : ''), filters)
  }
  scope :created_by, ->(user) { where(user_id: user.id) }
  scope :available, -> { where(status: 'available') }
  scope :checked_out, -> { where(status: 'checked_out') }
  scope :fire_sale, -> { where(has_fire_sale: true) }
  scope :by_brand, ->(brand) { where(brand: brand) }
  scope :by_location, ->(location) { where(location: location) }

  scope :text_search, ->(query) { ransack('name_or_brand_or_sku_or_qr_code_cont' => query).result }

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
  sortable by: ["name ASC", "brand ASC", "best_price ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w[bundle tags activities comments tasks]
  ransack_can_autocomplete

  validates_presence_of :name, message: :missing_sample_name
  validates_uniqueness_of :name, scope: :deleted_at
  validates_uniqueness_of :qr_code, allow_blank: true, scope: :deleted_at
  validates :status, inclusion: { in: %w[available checked_out reserved discontinued] }, allow_blank: true
  validate :users_for_shared_access

  before_save :nullify_blank_status

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page
    20
  end

  def self.sort_by
    "samples.created_at DESC"
  end

  # Check out the sample
  #----------------------------------------------------------------------------
  def checkout!(user)
    update!(
      status: 'checked_out',
      checked_out_at: Time.current,
      checked_out_by: user.id
    )
  end

  # Check in the sample
  #----------------------------------------------------------------------------
  def checkin!
    update!(
      status: 'available',
      checked_out_at: nil,
      checked_out_by: nil
    )
  end

  # Calculate discount percentage
  #----------------------------------------------------------------------------
  def discount_percentage
    return nil unless original_price.present? && best_price.present? && original_price > 0
    ((original_price - best_price) / original_price * 100).round(1)
  end

  # Display name with brand
  #----------------------------------------------------------------------------
  def full_name
    brand.present? ? "#{brand} - #{name}" : name
  end

  private

  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_sample) if self[:access] == "Shared" && permissions.none?
  end

  def nullify_blank_status
    self.status = 'available' if status.blank?
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_sample, self)
end
