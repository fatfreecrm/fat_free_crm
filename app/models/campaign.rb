# == Schema Information
# Schema version: 14
#
# Table name: campaigns
#
#  id                :integer(4)      not null, primary key
#  uuid              :string(36)
#  user_id           :integer(4)
#  name              :string(64)      default(""), not null
#  access            :string(8)       default("Private")
#  status            :string(64)
#  budget            :decimal(12, 2)
#  target_leads      :integer(4)
#  target_conversion :float
#  target_revenue    :decimal(12, 2)
#  actual_leads      :integer(4)
#  actual_conversion :float
#  actual_revenue    :decimal(12, 2)
#  starts_on         :date
#  ends_on           :date
#  objectives        :text
#  deleted_at        :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

class Campaign < ActiveRecord::Base
  belongs_to :user
  has_many :leads
  has_many :opportunities
  has_many :permissions, :as => :asset, :include => :user
  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :name, :message => "^Please specify campaign name."
  validates_uniqueness_of :name, :scope => :user_id
  validate :start_and_end_dates
  validate :users_for_shared_access

  before_create :set_campaign_status

  # Save the campaign along with its permissions if any.
  #----------------------------------------------------------------------------
  def save_with_permissions(users)
    if users && self[:access] == "Shared"
      users.each { |id| self.permissions << Permission.new(:user_id => id, :asset => self) }
    end
    save
  end

  private
  #----------------------------------------------------------------------------
  def set_campaign_status # before_create
    if self.ends_on and (self.ends_on < Date.today)
      self.status = "completed"
    else
      self.status = self.starts_on && (self.starts_on <= Date.today) ? "started" : "planned"
    end
  end

  # Make sure end date > start date.
  #----------------------------------------------------------------------------
  def start_and_end_dates
    if (self.starts_on && self.ends_on) && (self.starts_on > self.ends_on)
      errors.add(:ends_on, "^Please make sure the campaign end date is after the start date.")
    end
  end

  # Make sure at least one user has been selected if the campaign is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, "^Please specify users to share the campaign with.") if self[:access] == "Shared" && !self.permissions.any?
  end

end
