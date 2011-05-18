# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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
# Schema version: 27
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
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
#  persistence_token :string(255)     default(""), not null
#  perishable_token  :string(255)     default(""), not null
#  last_request_at   :datetime
#  last_login_at     :datetime
#  current_login_at  :datetime
#  last_login_ip     :string(255)
#  current_login_ip  :string(255)
#  login_count       :integer(4)      default(0), not null
#  deleted_at        :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  admin             :boolean(1)      not null
#  suspended_at      :datetime
#
class User < ActiveRecord::Base
  LDAP_ATTRIBUTES_MAP = {
    :email => :mail,
    :first_name => :givenname,
    :last_name => :sn,
    :phone => :telephonenumber,
    :mobile => :mobile
  }
  LDAP_ATTRIBUTES = LDAP_ATTRIBUTES_MAP.keys
  attr_protected :admin, :suspended_at

  before_create  :check_if_needs_approval
  before_destroy :check_if_current_user, :check_if_has_related_assets

  has_one     :avatar, :as => :entity, :dependent => :destroy  # Personal avatar.
  has_many    :avatars                                         # As owner who uploaded it, ex. Contact avatar.
  has_many    :comments, :as => :commentable                   # As owner who crated a comment.
  has_many    :accounts
  has_many    :campaigns
  has_many    :leads
  has_many    :contacts
  has_many    :opportunities
  has_many    :activities,  :dependent => :destroy
  has_many    :permissions, :dependent => :destroy
  has_many    :preferences, :dependent => :destroy
  named_scope :except, lambda { |user| { :conditions => [ "id != ? ", user.id ] } }
  named_scope :by_name, :order => "first_name, last_name, email"
  named_scope :active, :conditions => "suspended_at IS NULL"
  default_scope :order => "id DESC" # Show newest users first.

  simple_column_search :username, :first_name, :last_name, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

  acts_as_paranoid
  acts_as_authentic do |c|
    c.session_class = Authentication
    c.validates_uniqueness_of_login_field_options = { :message => :username_taken }
    c.validates_uniqueness_of_email_field_options = { :message => :email_in_use }
  end

  # Store current user in the class so we could access it from the activity
  # observer without extra authentication query.
  cattr_accessor :current_user

  validates_presence_of :username, :message => :missing_username
  validates_presence_of :email,    :message => :missing_email

  #named_scopes----------------------------------------------------------------
  
  named_scope :have_assigned_opportunities,
              :joins => "INNER JOIN opportunities ON opportunities.assigned_to = users.id",
              :order => "first_name ASC",
              :group => "users.first_name",
              :conditions => "opportunities.stage <> 'lost' AND opportunities.stage <> 'won'"
              
  #----------------------------------------------------------------------------
  def name
    self.first_name.blank? ? self.username : self.first_name
  end

  #----------------------------------------------------------------------------
  def full_name
    self.first_name.blank? || self.last_name.blank? ? self.email : "#{self.first_name} #{self.last_name}"
  end

  #----------------------------------------------------------------------------
  def suspended?
    self.suspended_at != nil
  end

  #----------------------------------------------------------------------------
  def awaits_approval?
    self.suspended? && self.login_count == 0 && Setting.user_signup == :needs_approval
  end

  #----------------------------------------------------------------------------
  def preference
    Preference.new(:user => self)
  end
  alias :pref :preference

  def self.update_or_create_from_ldap(username)
    if u = find_by_username(username)
      u.set_attributes_from_ldap
      u.save
      return u
    elsif details = LDAPAccess.get_user_details(username)
      u = User.new(:username => username)
      u.set_attributes_from_ldap( details )
      u.admin = true if User.count == 0
      u.save
      return u
    end
    return nil
  end

  def set_attributes_from_ldap( details = nil )
    details ||= LDAPAccess.get_user_details(username)
    unless details.nil?
      LDAP_ATTRIBUTES_MAP.each do |k,v|
        write_attribute(k, details[v])
      end
    end
    self
  end

  def assigned_opportunities
    Opportunity.assigned_to(:user => self, :order => "stage ASC").not_closed
  end
  protected

  def valid_ldap_credentials?(password)
    LDAPAccess.authenticate(self.username, password)
  end

  private

  # Suspend newly created user if signup requires an approval.
  #----------------------------------------------------------------------------
  def check_if_needs_approval
    self.suspended_at = Time.now if Setting.user_signup == :needs_approval && !self.admin
  end

  # Prevent current user from deleting herself.
  #----------------------------------------------------------------------------
  def check_if_current_user
    User.current_user && User.current_user != self
  end

  # Prevent deleting a user unless she has no artifacts left.
  #----------------------------------------------------------------------------
  def check_if_has_related_assets
    artifacts = %w(Account Campaign Lead Contact Opportunity Comment).inject(0) do |sum, asset|
      klass = asset.constantize
      sum += klass.assigned_to(self).count if asset != "Comment"
      sum += klass.created_by(self).count
    end
    artifacts == 0
  end

end
