# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  username            :string(32)      default(""), not null
#  email               :string(64)      default(""), not null
#  first_name          :string(32)
#  last_name           :string(32)
#  title               :string(64)
#  company             :string(64)
#  alt_email           :string(64)
#  phone               :string(32)
#  mobile              :string(32)
#  aim                 :string(32)
#  yahoo               :string(32)
#  google              :string(32)
#  skype               :string(32)
#  password_hash       :string(255)     default(""), not null
#  password_salt       :string(255)     default(""), not null
#  persistence_token   :string(255)     default(""), not null
#  perishable_token    :string(255)     default(""), not null
#  last_sign_in_at     :datetime
#  last_login_at       :datetime
#  current_login_at    :datetime
#  last_login_ip       :string(255)
#  current_login_ip    :string(255)
#  login_count         :integer         default(0), not null
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  admin               :boolean         default(FALSE), not null
#  suspended_at        :datetime
#  single_access_token :string(255)
#

class User < ActiveRecord::Base
  attr_protected :admin, :suspended_at

  devise :database_authenticatable, :registerable, :confirmable,
    :encryptable, :recoverable, :rememberable, :trackable, stretches: 20

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :title, :company, :group_ids

  before_create  :check_if_needs_approval
  before_destroy :check_if_has_related_assets

  has_one     :avatar, :as => :entity, :dependent => :destroy  # Personal avatar.
  has_many    :avatars                                         # As owner who uploaded it, ex. Contact avatar.
  has_many    :comments, :as => :commentable                   # As owner who created a comment.
  has_many    :accounts
  has_many    :campaigns
  has_many    :leads
  has_many    :contacts
  has_many    :opportunities
  has_many    :assigned_opportunities, :class_name => 'Opportunity', :foreign_key => 'assigned_to'
  has_many    :permissions, :dependent => :destroy
  has_many    :preferences, :dependent => :destroy
  has_many    :lists
  has_and_belongs_to_many :groups

  has_paper_trail :ignore => [:last_sign_in_at, :perishable_token]

  scope :by_id, -> { order('id DESC') }
  scope :except, ->(user) { where('id != ?', user.id).by_name }
  scope :by_name, -> { order('first_name, last_name, email') }

  scope :text_search, ->(query) {
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    where('upper(username) LIKE upper(:s) OR upper(first_name) LIKE upper(:s) OR upper(last_name) LIKE upper(:s)', :s => "%#{query}%")
  }

  scope :my, ->(current_user) { accessible_by(User.current_ability(current_user)) }

  scope :have_assigned_opportunities, -> {
    joins("INNER JOIN opportunities ON users.id = opportunities.assigned_to")
    .where("opportunities.stage <> 'lost' AND opportunities.stage <> 'won'")
    .select('DISTINCT(users.id), users.*')
  }

  # Store current user in the class so we could access it from the activity
  # observer without extra authentication query.
  # cattr_accessor :current_user

  validates :email, presence: { message: :missing_email },
    uniqueness: { message: :email_in_use },
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :username, uniqueness: { message: :username_taken },
    presence: { message: :missing_username },
    format: { with: /[a-zA-Z0-9_-]+/ }
  validates :password, presence: { if: :password_required? }, confirmation: true

  #----------------------------------------------------------------------------
  def name
    self.first_name.blank? ? self.username : self.first_name
  end

  #----------------------------------------------------------------------------
  def full_name
    self.first_name.blank? && self.last_name.blank? ? self.email : "#{self.first_name} #{self.last_name}".strip
  end

  #----------------------------------------------------------------------------
  def suspended?
    self.suspended_at != nil
  end

  #----------------------------------------------------------------------------
  def awaits_approval?
    self.suspended? && self.sign_in_count == 0 && Setting.user_signup == :needs_approval
  end

  def active_for_authentication?
    super and self.confirmed? and !self.awaits_approval? and !self.suspended?
  end

  def inactive_message
    if !self.confirmed?
      super
    elsif self.awaits_approval?
      I18n.t(:msg_account_not_approved)
    elsif self.suspended?
      I18n.t(:msg_invalig_login)
    else
      super
    end
  end

  #----------------------------------------------------------------------------
  def preference
    @preference ||= Preference.new(:user => self)
  end
  alias :pref :preference

  #----------------------------------------------------------------------------
  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.password_reset_instructions(self).deliver
  end

  # Override global I18n.locale if the user has individual local preference.
  #----------------------------------------------------------------------------
  def set_individual_locale
    I18n.locale = self.preference[:locale] if self.preference[:locale]
  end

  # Generate the value of single access token if it hasn't been set already.
  #----------------------------------------------------------------------------
  def to_json(options = nil)
    [name].to_json
  end

  def to_xml(options = nil)
    [name].to_xml
  end

  # Prevent current user from deleting herself.
  #----------------------------------------------------------------------------
  def check_if_current_user(user)
    user.nil? || user != self
    # User.current_user.nil? || User.current_user != self
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  private

  # Suspend newly created user if signup requires an approval.
  #----------------------------------------------------------------------------
  def check_if_needs_approval
    self.suspended_at = Time.now if Setting.user_signup == :needs_approval && !self.admin
  end

  # Prevent deleting a user unless she has no artifacts left.
  #----------------------------------------------------------------------------
  def check_if_has_related_assets
    artifacts = %w(Account Campaign Lead Contact Opportunity Comment Task).inject(0) do |sum, asset|
      klass = asset.constantize
      sum += klass.assigned_to(self).count if asset != "Comment"
      sum += klass.created_by(self).count
    end
    artifacts == 0
  end

  # Define class methods
  #----------------------------------------------------------------------------
  class << self

    def current_ability(current_user)
      Ability.new(current_user)
    end

    def can_signup?
      [ :allowed, :needs_approval ].include? Setting.user_signup
    end

  end

  ActiveSupport.run_load_hooks(:fat_free_crm_user, self)
end
