class Account < ActiveRecord::Base
  belongs_to :user
  has_many :permissions, :as => :asset, :include => :user
  acts_as_paranoid
  validates_presence_of :name, :message => "^Please specify account name."
  validates_uniqueness_of :name, :scope => :user_id

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
    location.gsub(/\s\d+(:?\s|$)/, " ") if location
  end

end
