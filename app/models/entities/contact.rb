# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

# == Schema Information
#
# Table name: contacts
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  lead_id         :integer
#  assigned_to     :integer
#  reports_to      :integer
#  first_name      :string(64)      default(""), not null
#  last_name       :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  title           :string(64)
#  department      :string(64)
#  source          :string(32)
#  email           :string(64)
#  alt_email       :string(64)
#  phone           :string(32)
#  mobile          :string(32)
#  fax             :string(32)
#  blog            :string(128)
#  linkedin        :string(128)
#  facebook        :string(128)
#  twitter         :string(128)
#  born_on         :date
#  do_not_call     :boolean         default(FALSE), not null
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#  skype           :string(128)
#

class Contact < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :lead
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_one     :account_contact, :dependent => :destroy
  has_one     :account, :through => :account_contact
  has_many    :contact_opportunities, :dependent => :destroy
  has_many    :opportunities, :through => :contact_opportunities, :uniq => true, :order => "opportunities.id DESC"
  has_many    :tasks, :as => :asset, :dependent => :destroy#, :order => 'created_at DESC'
  has_one     :business_address, :dependent => :destroy, :as => :addressable, :class_name => "Address", :conditions => "address_type = 'Business'"
  has_many    :addresses, :dependent => :destroy, :as => :addressable, :class_name => "Address" # advanced search uses this
  has_many    :emails, :as => :mediator

  has_ransackable_associations %w(account opportunities tags activities emails addresses comments tasks)
  ransack_can_autocomplete

  serialize :subscribed_users, Set

  accepts_nested_attributes_for :business_address, :allow_destroy => true, :reject_if => proc {|attributes| Address.reject_address(attributes)}
    
  scope :created_by, lambda { |user| { :conditions => [ "user_id = ?", user.id ] } }
  scope :assigned_to, lambda { |user| { :conditions => ["assigned_to = ?", user.id ] } }

  scope :text_search, lambda { |query|
    t = Contact.arel_table
    # We can't always be sure that names are entered in the right order, so we must
    # split the query into all possible first/last name permutations.
    name_query = if query.include?(" ")
      scope, *rest = query.name_permutations.map{ |first, last|
        t[:first_name].matches("%#{first}%").and(t[:last_name].matches("%#{last}%"))
      }
      rest.map{|r| scope = scope.or(r)} if scope
      scope
    else
      t[:first_name].matches("%#{query}%").or(t[:last_name].matches("%#{query}%"))
    end

    other = t[:email].matches("%#{query}%").or(t[:alt_email].matches("%#{query}%"))
    other = other.or(t[:phone].matches("%#{query}%")).or(t[:mobile].matches("%#{query}%"))
    
    where( name_query.nil? ? other : name_query.or(other) )
  }

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail :ignore => [ :subscribed_users ]
  
  has_fields
  exportable
  sortable :by => [ "first_name ASC",  "last_name ASC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  validates_presence_of :first_name, :message => :missing_first_name
  validates_presence_of :last_name, :message => :missing_last_name if Setting.require_last_names
  validate :users_for_shared_access

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20                  ; end
  def self.first_name_position ; "before" ; end

  #----------------------------------------------------------------------------
  def full_name(format = nil)
    if format.nil? || format == "before"
      "#{self.first_name} #{self.last_name}"
    else
      "#{self.last_name}, #{self.first_name}"
    end
  end
  alias :name :full_name

  # Backend handler for [Create New Contact] form (see contact/create).
  #----------------------------------------------------------------------------
  def save_with_account_and_permissions(params)
    save_account(params)
    self.opportunities << Opportunity.find(params[:opportunity]) unless params[:opportunity].blank?
    self.save
  end

  # Backend handler for [Update Contact] form (see contact/update).
  #----------------------------------------------------------------------------
  def update_with_account_and_permissions(params)
    save_account(params)
    # Must set access before user_ids, because user_ids= method depends on access value.
    self.access = params[:contact][:access] if params[:contact][:access]
    self.attributes = params[:contact]
    self.save
  end

  # Attach given attachment to the contact if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    unless self.send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      self.send(attachment.class.name.tableize) << attachment
    end
  end

  # Discard given attachment from the contact.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Opportunities
      self.send(attachment.class.name.tableize).delete(attachment)
    end
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_for(model, account, opportunity, params)
    attributes = {
      :lead_id     => model.id,
      :user_id     => params[:account][:user_id],
      :assigned_to => params[:account][:assigned_to],
      :access      => params[:access]
    }
    %w(first_name last_name title source email alt_email phone mobile blog linkedin facebook twitter skype do_not_call background_info).each do |name|
      attributes[name] = model.send(name.intern)
    end
    
    contact = Contact.new(attributes)
    
    # Set custom fields.
    if model.class.respond_to?(:fields)
      model.class.fields.each do |field|
        if contact.respond_to?(field.name)
          contact.send "#{field.name}=", model.send(field.name)
        end
      end
    end
    
    contact.business_address = Address.new(:street1 => model.business_address.street1, :street2 => model.business_address.street2, :city => model.business_address.city, :state => model.business_address.state, :zipcode => model.business_address.zipcode, :country => model.business_address.country, :full_address => model.business_address.full_address, :address_type => "Business") unless model.business_address.nil?

    # Save the contact only if the account and the opportunity have no errors.
    if account.errors.empty? && opportunity.errors.empty?
      # Note: contact.account = account doesn't seem to work here.
      contact.account_contact = AccountContact.new(:account => account, :contact => contact) unless account.id.blank?
      contact.opportunities << opportunity unless opportunity.id.blank?
      if contact.access != "Lead" || model.nil?
        contact.save
      else
        contact.save_with_model_permissions(model)
      end
    end
    contact
  end

  private
  # Make sure at least one user has been selected if the contact is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_contact) if self[:access] == "Shared" && !self.permissions.any?
  end
  
  # Handles the saving of related accounts
  #----------------------------------------------------------------------------
  def save_account(params)
    if params[:account][:id] == "" || params[:account][:name] == ""
      self.account = nil
    else
      account = Account.create_or_select_for(self, params[:account])
      if self.account != account and account.id.present?
        self.account_contact = AccountContact.new(:account => account, :contact => self)
      end
    end
    self.reload unless self.new_record? # ensure the account association is updated
  end

end
