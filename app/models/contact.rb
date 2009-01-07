# == Schema Information
# Schema version: 14
#
# Table name: contacts
#
#  id          :integer(4)      not null, primary key
#  uuid        :string(36)
#  user_id     :integer(4)
#  assigned_to :integer(4)
#  reports_to  :integer(4)
#  first_name  :string(64)      default(""), not null
#  last_name   :string(64)      default(""), not null
#  access      :string(8)       default("Private")
#  title       :string(64)
#  department  :string(64)
#  source      :string(32)
#  email       :string(64)
#  alt_email   :string(64)
#  phone       :string(32)
#  mobile      :string(32)
#  fax         :string(32)
#  blog        :string(128)
#  linkedin    :string(128)
#  facebook    :string(128)
#  twitter     :string(128)
#  address     :string(255)
#  born_on     :date
#  do_not_call :boolean(1)      not null
#  notes       :text
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Contact < ActiveRecord::Base
  belongs_to :user
  belongs_to :lead
  has_one :account_contact, :dependent => :destroy
  has_one :account, :through => :account_contact
  has_many :contact_opportunities, :dependent => :destroy
  has_many :opportunities, :through => :contact_opportunities, :uniq => true
  has_many :permissions, :as => :asset, :include => :user
  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :first_name, :message => "^Please specify first name."
  validates_presence_of :last_name, :message => "^Please specify last name."

  #----------------------------------------------------------------------------
  def full_name
    self.first_name + " " + self.last_name
  end

  # Save the contact along with its permissions if any.
  #----------------------------------------------------------------------------
  def save_with_permissions(users)
    if users && self[:access] == "Shared"
      users.each { |id| self.permissions << Permission.new(:user_id => id, :asset => self) }
    end
    save
  end

  # Save the contact copying lead permissions.
  #----------------------------------------------------------------------------
  def save_with_lead_permissions(lead)
    self.access = lead.access
    if lead.access == "Shared"
      lead.permissions.each do |permission|
        self.permissions << Permission.new(:user_id => permission.user_id, :asset => self)
      end
    end
    save
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_for_lead(lead, account, opportunity, params)
    attributes = {
      :user_id     => params[:account][:user_id],
      :assigned_to => params[:account][:assigned_to],
      :access      => params[:access]
    }
    %w(first_name last_name title source email alt_email phone mobile blog linkedin facebook twitter address do_not_call notes).each do |name|
      attributes[name] = lead.send(name.intern)
    end
    contact = Contact.new(attributes)

    # Save the contact only if the account and the opportunity have no errors.
    if account.errors.empty? && opportunity.errors.empty?
      # Note: contact.account = account doesn't seem to work here.
      contact.account_contact = AccountContact.new(:account => account, :contact => contact) unless account.id.blank?
      contact.opportunities << opportunity unless opportunity.id.blank?
      if contact.access != "Lead"
        contact.save_with_permissions(params[:users])
      else
        contact.save_with_lead_permissions(lead)
      end
    end
    contact
  end

end
