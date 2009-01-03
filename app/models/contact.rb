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
  has_many :permissions, :as => :asset, :include => :user
  has_many :accounts, :through => :account_contacts
  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :first_name, :message => "^Please specify first name."
  validates_presence_of :last_name, :message => "^Please specify last name."

  #----------------------------------------------------------------------------
  def full_name
    self.first_name << " " << self.last_name
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.convert_from_lead(lead, account, params)
    attributes = {
      :user_id     => params[:lead][:user_id],
      :assigned_to => params[:lead][:assigned_to],
      :access      => params[:lead][:access] == "Lead" ? lead.access : params[:lead][:access]
    }
    %w(first_name last_name title source email alt_email phone mobile blog linkedin facebook twitter address do_not_call notes).each do |name|
      attributes[name] = lead.send(name.intern)
    end
    contact = Contact.new(attributes)

    if params[:access] == "Shared"
      params[:users].each do |id|
        contact.permissions << Permission.new(:user_id => id, :asset => contact)
      end
    else
      if params[:access] == "Lead" && lead.access == "Shared" # Copy lead permissions.
        lead.permissions.each do |permission|
          contact.permissions << Permission.new(:user_id => permission.user_id, :asset => contact)
        end
      end
    end
    contact.save

    AccountContact.create(:account => account, :contact => contact)
    contact
  end

end
