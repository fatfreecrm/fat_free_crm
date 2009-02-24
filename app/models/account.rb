# == Schema Information
# Schema version: 16
#
# Table name: accounts
#
#  id               :integer(4)      not null, primary key
#  uuid             :string(36)
#  user_id          :integer(4)
#  assigned_to      :integer(4)
#  name             :string(64)      default(""), not null
#  access           :string(8)       default("Private")
#  notes            :string(255)
#  website          :string(64)
#  tall_free_phone  :string(32)
#  phone            :string(32)
#  fax              :string(32)
#  billing_address  :string(255)
#  shipping_address :string(255)
#  deleted_at       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#

class Account < ActiveRecord::Base
  belongs_to :user
  has_many :account_contacts, :dependent => :destroy
  has_many :contacts, :through => :account_contacts, :uniq => true
  has_many :account_opportunities, :dependent => :destroy
  has_many :opportunities, :through => :account_opportunities, :uniq => true, :order => "id DESC"

  uses_mysql_uuid
  uses_user_permissions
  acts_as_commentable
  acts_as_paranoid

  validates_presence_of :name, :message => "^Please specify account name."
  validates_uniqueness_of :name
  validate :users_for_shared_access

  # Extract last line of billing address and get rid of numeric zipcode.
  #----------------------------------------------------------------------------
  def location
    return "" unless self[:billing_address]
    location = self[:billing_address].strip.split("\n").last
    location.gsub(/(^|\s+)\d+(:?\s+|$)/, " ") if location
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_or_select_for(model, params, users)
    if params[:id]
      account = Account.find(params[:id])
    else
      account = Account.new(params)
      if account.access != "Lead" || model.nil?
        account.save_with_permissions(users)
      else
        account.save_with_model_permissions(model)
      end
    end
    account
  end

  private
  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, "^Please specify users to share the account with.") if self[:access] == "Shared" && !self.permissions.any?
  end

end
