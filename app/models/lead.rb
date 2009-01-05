# == Schema Information
# Schema version: 14
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
#  notes       :text
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :permissions, :as => :asset, :include => :user
  named_scope :converted, :conditions => "status='converted'"
  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :first_name, :message => "^Please specify first name."
  validates_presence_of :last_name, :message => "^Please specify last name."

  after_create :update_campaign_counters

  # Save the lead along with its permissions.
  #----------------------------------------------------------------------------
  def save_with_permissions(users)
    if self[:access] == "Campaign"  # Copy campaign permissions.
      campaign = Campaign.find(self[:campaign_id])
      self[:access] = campaign[:access]
      if campaign[:access] == "Shared"
        campaign.permissions.each do |permission|
          self.permissions << Permission.new(:user_id => permission.user_id, :asset => self)
        end
      end
    elsif self[:access] == "Shared"
      users.each { |id| self.permissions << Permission.new(:user_id => id, :asset => self) }
    end
    save
  end

  # Promote the lead by creating contact and optional opportunity. Upon
  # successful promotion Lead status gets set to :converted.
  #----------------------------------------------------------------------------
  def promote(params)
    account     = Account.create_or_select_for_lead(self, params[:account], params[:users])
    opportunity = Opportunity.create_for_lead(self, params[:opportunity], params[:users])
    contact     = Contact.convert_from_lead(self, account, params)

    # TODO : save ContactOpportunity
    # TODO : save AccountOpportunity
    return account, opportunity, contact
  end

  #----------------------------------------------------------------------------
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  private
  #----------------------------------------------------------------------------
  def update_campaign_counters
    if self.campaign_id
      Campaign.increment_counter(:actual_leads, self.campaign_id)
      Campaign.update(self.campaign_id, { :actual_conversion => Lead.converted.count * 100.0 / Lead.count })
    end
  end

  # Copies validation errors from other object to self. Returns true if there
  # are errors, false otherwise.
  #----------------------------------------------------------------------------
  def validation_errors(model)
    model.errors.each do |key, value|
      self.errors.add(key, value)
    end
    self.errors.size > 0
  end

end
