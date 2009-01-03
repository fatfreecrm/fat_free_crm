# == Schema Information
# Schema version: 14
#
# Table name: accounts
#
#  id               :integer(4)      not null, primary key
#  uuid             :string(36)
#  user_id          :integer(4)
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
  has_many :contacts, :through => :account_contacts
  has_many :opportunities, :through => :account_opportunities
  has_many :permissions, :as => :asset, :include => :user
  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :name, :message => "^Please specify account name."
  validates_uniqueness_of :name

  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def validate
    errors.add(:access, "^Please specify users to share the account with.") if self[:access] == "Shared" && self.permissions.size <= 0
  end

  # Save the account along with its permissions if any.
  #----------------------------------------------------------------------------
  def save_with_permissions(users)
    if users && self[:access] == "Shared"
      users.each { |id| self.permissions << Permission.new(:user_id => id, :asset => self) }
    end
    save
  end

  # Extract last line of billing address and get rid of numeric zipcode.
  #----------------------------------------------------------------------------
  def location
    return "" unless self[:billing_address]
    location = self[:billing_address].strip.split("\n").last
    location.gsub(/(^|\s+)\d+(:?\s+|$)/, " ") if location
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_for_lead(lead, params)
    if params[:request] == "select"                   # Select existing account.
      account = Account.find(params[:account])
    elsif params[:request] == "create"                # Create new account.
      account = Account.new(
        :name    => params[:account_name],
        :user_id => params[:lead][:user_id],
        :access  => params[:lead][:access] == "Lead" ? lead.access : params[:lead][:access]
      )
      if params[:access] == "Shared"
        params[:users].each do |id|
          account.permissions << Permission.new(:user_id => id, :asset => account)
        end
      else
        if params[:access] == "Lead" && lead.access == "Shared" # Copy lead permissions.
          lead.permissions.each do |permission|
            account.permissions << Permission.new(:user_id => permission.user_id, :asset => account)
          end
        end
      end
      account.save
    end
    account
  end

end
