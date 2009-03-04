# == Schema Information
# Schema version: 16
#
# Table name: leads
#
#  id          :integer(4)      not null, primary key
#  uuid        :string(36)
#  user_id     :integer(4)
#  campaign_id :integer(4)
#  assigned_to :integer(4)
#  first_name  :string(64)      default(""), not null
#  last_name   :string(64)      default(""), not null
#  access      :string(8)       default("Private")
#  title       :string(64)
#  company     :string(64)
#  source      :string(32)
#  status      :string(32)
#  referred_by :string(64)
#  email       :string(64)
#  alt_email   :string(64)
#  phone       :string(32)
#  mobile      :string(32)
#  blog        :string(128)
#  linkedin    :string(128)
#  facebook    :string(128)
#  twitter     :string(128)
#  address     :string(255)
#  rating      :integer(4)      default(0), not null
#  do_not_call :boolean(1)      not null
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_one :contact
  has_many :tasks, :as => :asset, :dependent => :destroy, :order => 'created_at DESC'
  named_scope :only, lambda { |filters| { :conditions => [ "status IN (?)" + (filters.delete("other") ? " OR status IS NULL" : ""), filters ] } }
  named_scope :converted, :conditions => "status='converted'"
  named_scope :for_campaign, lambda { |id| { :conditions => [ "campaign_id=?", id ] } }

  uses_mysql_uuid
  uses_user_permissions
  acts_as_commentable
  acts_as_paranoid

  validates_presence_of :first_name, :message => "^Please specify first name."
  validates_presence_of :last_name, :message => "^Please specify last name."
  validate :users_for_shared_access

  after_create  :increment_leads_count
  after_destroy :decrement_leads_count

  # Save the lead along with its permissions.
  #----------------------------------------------------------------------------
  def save_with_permissions(users)
    if self[:access] == "Campaign" &&self[:campaign_id] # Copy campaign permissions.
      save_with_model_permissions(Campaign.find(self[:campaign_id]))
    else
      super(users) # invoke :save_with_permissions in plugin.
    end
  end

  # Promote the lead by creating contact and optional opportunity. Upon
  # successful promotion Lead status gets set to :converted.
  #----------------------------------------------------------------------------
  def promote(params)
    account     = Account.create_or_select_for(self, params[:account], params[:users])
    opportunity = Opportunity.create_for(self, account, params[:opportunity], params[:users])
    contact     = Contact.create_for(self, account, opportunity, params)

    return account, opportunity, contact
  end

  #----------------------------------------------------------------------------
  def convert(with_opportunity = true)
    update_attributes(:status => "converted")
  end

  #----------------------------------------------------------------------------
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  alias :name :full_name

  private
  #----------------------------------------------------------------------------
  def increment_leads_count
    if self.campaign_id
      Campaign.increment_counter(:leads_count, self.campaign_id)
    end
  end

  #----------------------------------------------------------------------------
  def decrement_leads_count
    if self.campaign_id
      Campaign.decrement_counter(:leads_count, self.campaign_id)
    end
  end

  # Make sure at least one user has been selected if the lead is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, "^Please specify users to share the lead with.") if self[:access] == "Shared" && !self.permissions.any?
  end

end
