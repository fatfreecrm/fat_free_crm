class User < ActiveRecord::Base
  
  has_many :accounts
  has_many :permissions
  has_many :preferences
  has_many :shared_accounts, :through => :permissions, :source => :asset, :source_type => "Account", :class_name => "Account"
  acts_as_paranoid

  #----------------------------------------------------------------------------
  def preference
    Preference.new(:user => self)
  end

  # Selects accounts owned by the user plus all accounts shared with the user.
  #----------------------------------------------------------------------------
  def owned_and_shared_accounts
    Account.find_by_sql [ 'SELECT * FROM accounts WHERE deleted_at IS NULL AND (user_id=? OR id IN (SELECT asset_id FROM permissions WHERE asset_type="Account" AND user_id=?))', self.id, self.id ]
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
