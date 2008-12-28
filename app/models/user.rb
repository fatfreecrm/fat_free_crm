# == Schema Information
# Schema version: 11
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  uuid              :string(36)
#  username          :string(32)      default(""), not null
#  email             :string(64)      default(""), not null
#  first_name        :string(32)
#  last_name         :string(32)
#  title             :string(64)
#  company           :string(64)
#  alt_email         :string(64)
#  phone             :string(32)
#  mobile            :string(32)
#  aim               :string(32)
#  yahoo             :string(32)
#  google            :string(32)
#  skype             :string(32)
#  password_hash     :string(255)     default(""), not null
#  password_salt     :string(255)     default(""), not null
#  remember_token    :string(255)     default(""), not null
#  perishable_token  :string(255)     default(""), not null
#  openid_identifier :string(255)
#  last_request_at   :datetime
#  last_login_at     :datetime
#  current_login_at  :datetime
#  last_login_ip     :string(255)
#  current_login_ip  :string(255)
#  login_count       :integer(4)      default(0), not null
#  deleted_at        :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

class User < ActiveRecord::Base
  
  has_many :accounts
  has_many :campaigns
  has_many :leads
  has_many :contacts
  has_many :opportunities
  has_many :permissions
  has_many :preferences
  has_many :shared_accounts, :through => :permissions, :source => :asset, :source_type => "Account", :class_name => "Account"
  named_scope :all_except, lambda { | user | { :conditions => "id != #{user.id}" } }
  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of   :username, :message => "^Please specify the username."
  validates_presence_of   :email,    :message => "^Please specify your email address."
  validates_uniqueness_of :username, :message => "^This username has been already taken."
  validates_uniqueness_of :email,    :message => "^There is another user with the same email."

  #----------------------------------------------------------------------------
  def full_name
    self.first_name && self.last_name ? "#{self.first_name} #{self.last_name}" : self.email
  end

  #----------------------------------------------------------------------------
  def preference
    Preference.new(:user => self)
  end

  # Selects accounts owned by the user plus all accounts shared with the user.
  #----------------------------------------------------------------------------
  def owned_and_shared_accounts
    Account.find_by_sql [ 'SELECT * FROM accounts WHERE deleted_at IS NULL AND (user_id=? OR id IN (SELECT asset_id FROM permissions WHERE asset_type="Account" AND user_id=?)) ORDER BY id DESC', self.id, self.id ]
  end

  # All of the following code is for OpenID integration.
  #----------------------------------------------------------------------------
  acts_as_authentic(
    :login_field => :username,
    :session_class => Authentication,
    :login_field_validation_options => { :if => :openid_identifier_blank? }, 
    :password_field_validation_options => { :if => :openid_identifier_blank? }
  )
  
  validate :normalize_openid_identifier
  validates_uniqueness_of :openid_identifier, :allow_blank => true
  
  # For acts_as_authentic configuration
  #----------------------------------------------------------------------------
  def openid_identifier_blank?
    openid_identifier.blank?
  end
  
  #----------------------------------------------------------------------------
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end
  
  #----------------------------------------------------------------------------
  private
  def normalize_openid_identifier
    begin
      self.openid_identifier = OpenIdAuthentication.normalize_url(openid_identifier) if !openid_identifier.blank?
    rescue OpenIdAuthentication::InvalidOpenId => e
      errors.add(:openid_identifier, e.message)
    end
  end

end
