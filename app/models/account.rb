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
# Schema version: 23
#
# Table name: accounts
#
#  id               :integer(4)      not null, primary key
#  user_id          :integer(4)
#  assigned_to      :integer(4)
#  name             :string(64)      default(""), not null
#  access           :string(8)       default("Private")
#  website          :string(64)
#  toll_free_phone  :string(32)
#  phone            :string(32)
#  fax              :string(32)
#  billing_address  :string(255)
#  shipping_address :string(255)
#  deleted_at       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#
class Account < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many    :account_contacts, :dependent => :destroy
  has_many    :contacts, :through => :account_contacts, :uniq => true
  has_many    :account_opportunities, :dependent => :destroy
  has_many    :opportunities, :through => :account_opportunities, :uniq => true, :order => "opportunities.id DESC"
  has_many    :tasks, :as => :asset, :dependent => :destroy, :order => 'created_at DESC'
  has_many    :activities, :as => :subject, :order => 'created_at DESC'

  named_scope :created_by, lambda { |user| { :conditions => ["user_id = ? ", user.id ] } }
  named_scope :assigned_to, lambda { |user| { :conditions => ["assigned_to = ? ", user.id ] } }

  simple_column_search :name, :match => :middle, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }
  uses_user_permissions
  acts_as_commentable
  acts_as_paranoid
  sortable :by => [ "name ASC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  validates_presence_of :name, :message => :missing_account_name
  validates_uniqueness_of :name
  validate :users_for_shared_access

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20     ; end
  def self.outline  ; "long" ; end

  # Extract last line of billing address and get rid of numeric zipcode.
  #----------------------------------------------------------------------------
  def location
    return "" unless self[:billing_address]
    location = self[:billing_address].strip.split("\n").last
    location.gsub(/(^|\s+)\d+(:?\s+|$)/, " ").strip if location
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_or_select_for(model, params, users)
    if params[:id]
      account = Account.find(params[:id])
    else
      account = Account.new(params)
      if account.access != "Lead" || model.nil?
        account.save_with_permissions(users)
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

end
