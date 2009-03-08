# == Schema Information
# Schema version: 16
#
# Table name: opportunities
#
#  id          :integer(4)      not null, primary key
#  uuid        :string(36)
#  user_id     :integer(4)
#  campaign_id :integer(4)
#  assigned_to :integer(4)
#  name        :string(64)      default(""), not null
#  access      :string(8)       default("Private")
#  source      :string(32)
#  stage       :string(32)
#  probability :integer(4)
#  amount      :decimal(12, 2)
#  discount    :decimal(12, 2)
#  closes_on   :date
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Opportunity < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  belongs_to :campaign
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_one :account_opportunity, :dependent => :destroy
  has_one :account, :through => :account_opportunity
  has_many :contact_opportunities, :dependent => :destroy
  has_many :contacts, :through => :contact_opportunities, :uniq => true, :order => "id DESC"
  has_many :tasks, :as => :asset, :dependent => :destroy, :order => 'created_at DESC'
  named_scope :only, lambda { |filters| { :conditions => [ "stage IN (?)" + (filters.delete("other") ? " OR stage IS NULL" : ""), filters ] } }

  uses_mysql_uuid
  uses_user_permissions
  acts_as_commentable
  acts_as_paranoid

  validates_presence_of :name, :message => "^Please specify the opportunity name."
  validates_uniqueness_of :name, :scope => :user_id
  validates_numericality_of [ :probability, :amount, :discount ], :allow_nil => true
  validate :users_for_shared_access

  after_create  :increment_opportunities_count
  after_destroy :decrement_opportunities_count

  #----------------------------------------------------------------------------
  def weighted_amount
    ((amount || 0) - (discount || 0)) * (probability || 0) / 100.0
  end

  # Backend handler for [Create New Opportunity] form (see opportunity/create).
  #----------------------------------------------------------------------------
  def save_with_account_and_permissions(params)
    account = Account.create_or_select_for(self, params[:account], params[:users])
    self.account_opportunity = AccountOpportunity.new(:account => account, :opportunity => self) unless account.id.blank?
    self.contacts << Contact.find(params[:contact]) unless params[:contact].blank?
    self.campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
    save_with_permissions(params[:users])
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_for(model, account, params, users)
    opportunity = Opportunity.new(params)

    # Save the opportunity if its name was specified and account has no errors.
    if opportunity.name? && account.errors.empty?
      # Note: opportunity.account = account doesn't seem to work here.
      opportunity.account_opportunity = AccountOpportunity.new(:account => account, :opportunity => opportunity) unless account.id.blank?
      if opportunity.access != "Lead" || model.nil?
        opportunity.save_with_permissions(users)
      else
        opportunity.save_with_model_permissions(model)
      end
    end
    opportunity
  end

  private
  # Make sure at least one user has been selected if the contact is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, "^Please specify users to share the opportunity with.") if self[:access] == "Shared" && !self.permissions.any?
  end

  #----------------------------------------------------------------------------
  def increment_opportunities_count
    if self.campaign_id
      Campaign.increment_counter(:opportunities_count, self.campaign_id)
    end
  end

  #----------------------------------------------------------------------------
  def decrement_opportunities_count
    if self.campaign_id
      Campaign.decrement_counter(:opportunities_count, self.campaign_id)
    end
  end

end
