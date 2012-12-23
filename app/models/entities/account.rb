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
# Table name: accounts
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  assigned_to     :integer
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  website         :string(64)
#  toll_free_phone :string(32)
#  phone           :string(32)
#  fax             :string(32)
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  email           :string(64)
#  background_info :string(255)
#  rating          :integer         default(0), not null
#  category        :string(32)
#

class Account < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many    :account_contacts, :dependent => :destroy
  has_many    :contacts, :through => :account_contacts, :uniq => true
  has_many    :account_opportunities, :dependent => :destroy
  has_many    :opportunities, :through => :account_opportunities, :uniq => true, :order => "opportunities.id DESC"
  has_many    :tasks, :as => :asset, :dependent => :destroy#, :order => 'created_at DESC'
  has_one     :billing_address, :dependent => :destroy, :as => :addressable, :class_name => "Address", :conditions => "address_type = 'Billing'"
  has_one     :shipping_address, :dependent => :destroy, :as => :addressable, :class_name => "Address", :conditions => "address_type = 'Shipping'"
  has_many    :addresses, :dependent => :destroy, :as => :addressable, :class_name => "Address" # advanced search uses this
  has_many    :emails, :as => :mediator

  serialize :subscribed_users, Set

  accepts_nested_attributes_for :billing_address,  :allow_destroy => true, :reject_if => proc {|attributes| Address.reject_address(attributes)}
  accepts_nested_attributes_for :shipping_address, :allow_destroy => true, :reject_if => proc {|attributes| Address.reject_address(attributes)}

  scope :state, lambda { |filters|
    where('category IN (?)' + (filters.delete('other') ? ' OR category IS NULL' : ''), filters)
  }
  scope :created_by, lambda { |user| where(:user_id => user.id) }
  scope :assigned_to, lambda { |user| where(:assigned_to => user.id) }

  scope :text_search, lambda { |query| search('name_or_email_cont' => query).result }

  scope :visible_on_dashboard, lambda { |user|
    # Show accounts which either belong to the user and are unassigned, or are assigned to the user
    where('(user_id = :user_id AND assigned_to IS NULL) OR assigned_to = :user_id', :user_id => user.id)
  }

  scope :by_name, order(:name)

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail :ignore => [ :subscribed_users ]
  has_fields
  exportable
  sortable :by => [ "name ASC", "rating DESC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  has_ransackable_associations %w(contacts opportunities tags activities emails addresses comments tasks)
  ransack_can_autocomplete

  validates_presence_of :name, :message => :missing_account_name
  validates_uniqueness_of :name, :scope => :deleted_at
  validate :users_for_shared_access
  before_save :nullify_blank_category

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20 ; end
  
  # Extract last line of billing address and get rid of numeric zipcode.
  #----------------------------------------------------------------------------
  def location
    return "" unless self[:billing_address]
    location = self[:billing_address].strip.split("\n").last
    location.gsub(/(^|\s+)\d+(:?\s+|$)/, " ").strip if location
  end

  # Attach given attachment to the account if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    unless self.send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      self.send(attachment.class.name.tableize) << attachment
    end
  end

  # Discard given attachment from the account.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Contacts, Opportunities
      self.send(attachment.class.name.tableize).delete(attachment)
    end
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_or_select_for(model, params)
    if params[:id].present?
      account = Account.find(params[:id])
    else
      account = Account.new(params)
      if account.access != "Lead" || model.nil?
        account.save
      else
        account.save_with_model_permissions(model)
      end
    end
    account
  end

  private
  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_account) if self[:access] == "Shared" && !self.permissions.any?
  end

  def nullify_blank_category
    self.category = nil if self.category.blank?
  end
end
