# frozen_string_literal: true

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
#  email               :string(254)     default(""), not null
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
#  encrypted_password  :string(255)     default(""), not null
#  password_salt       :string(255)     default(""), not null
#  last_sign_in_at     :datetime
#  current_sign_in_at  :datetime
#  last_sign_in_ip     :string(255)
#  current_sign_in_ip  :string(255)
#  sign_in_count       :integer         default(0), not null
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  admin               :boolean         default(FALSE), not null
#  suspended_at        :datetime
#  unconfirmed_email   :string(254)     default(""), not null
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  remember_token          :string(255)
#  remember_created_at     :datetime
#  authentication_token    :string(255)
#  confirmation_token      :string(255)
#  confirmed_at            :datetime
#  confirmation_sent_at    :datetime
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :encryptable, :recoverable, :rememberable, :trackable
  before_create :suspend_if_needs_approval

  has_one :avatar, as: :entity, dependent: :destroy  # Personal avatar.
  has_many :avatars                                  # As owner who uploaded it, ex. Contact avatar.
  has_many :comments, as: :commentable               # As owner who created a comment.
  has_many :accounts
  has_many :campaigns
  has_many :leads
  has_many :contacts
  has_many :opportunities
  has_many :assigned_opportunities, class_name: 'Opportunity', foreign_key: 'assigned_to'
  has_many :permissions, dependent: :destroy
  has_many :preferences, class_name: 'Preference', dependent: :destroy
  has_many :lists
  has_and_belongs_to_many :groups

  has_paper_trail versions: { class_name: 'Version' }, ignore: [:last_sign_in_at]

  scope :by_id, -> { order('id DESC') }
  # TODO: /home/clockwerx/.rbenv/versions/2.5.3/lib/ruby/gems/2.5.0/gems/activerecord-5.2.3/lib/active_record/scoping/named.rb:175:in `scope': You tried to define a scope named "without" on the model "User", but ActiveRecord::Relation already defined an instance method with the same name. (ArgumentError)
  scope :without_user, ->(user) { where('id != ?', user.id).by_name }
  scope :by_name, -> { order('first_name, last_name, email') }

  scope :text_search, lambda { |query|
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    where('upper(username) LIKE upper(:s) OR upper(email) LIKE upper(:s) OR upper(first_name) LIKE upper(:s) OR upper(last_name) LIKE upper(:s)', s: "%#{query}%")
  }

  scope :my, ->(current_user) { accessible_by(current_user.ability) }

  scope :have_assigned_opportunities, lambda {
    joins("INNER JOIN opportunities ON users.id = opportunities.assigned_to")
      .where("opportunities.stage <> 'lost' AND opportunities.stage <> 'won'")
      .select('DISTINCT(users.id), users.*')
  }

  validates :email,
            presence: { message: :missing_email },
            length: { minimum: 3, maximum: 254 },
            uniqueness: { message: :email_in_use, case_sensitive: false },
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :username,
            uniqueness: { message: :username_taken, case_sensitive: false },
            presence: { message: :missing_username },
            format: { with: /\A[a-z0-9_-]+\z/i }
  validates :password,
            presence: { if: :password_required? },
            confirmation: true

  #----------------------------------------------------------------------------
  def name
    first_name.blank? ? username : first_name
  end

  #----------------------------------------------------------------------------
  def full_name
    first_name.blank? && last_name.blank? ? email : "#{first_name} #{last_name}".strip
  end

  #----------------------------------------------------------------------------
  def suspended?
    suspended_at != nil
  end

  #----------------------------------------------------------------------------
  def awaits_approval?
    suspended? && sign_in_count == 0 && Setting.user_signup == :needs_approval
  end

  def active_for_authentication?
    super && confirmed? && !awaits_approval? && !suspended?
  end

  def inactive_message
    if !confirmed?
      super
    elsif awaits_approval?
      I18n.t(:msg_account_not_approved)
    elsif suspended?
      I18n.t(:msg_invalig_login)
    else
      super
    end
  end

  #----------------------------------------------------------------------------
  def preference
    @preference ||= preferences.build
  end
  alias pref preference

  # Override global I18n.locale if the user has individual local preference.
  #----------------------------------------------------------------------------
  def set_individual_locale
    I18n.locale = preference[:locale] if preference[:locale]
  end

  # Generate the value of single access token if it hasn't been set already.
  #----------------------------------------------------------------------------
  def to_json(_options = nil)
    [name].to_json
  end

  def to_xml(_options = nil)
    [name].to_xml
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  # Returns permissions ability object.
  #----------------------------------------------------------------------------
  def ability
    @ability ||= Ability.new(self)
  end

  # Returns true if this user is allowed to be destroyed.
  #----------------------------------------------------------------------------
  def destroyable?(current_user)
    current_user != self && !has_related_assets?
  end

  # Suspend newly created user if signup requires an approval.
  #----------------------------------------------------------------------------
  def suspend_if_needs_approval
    self.suspended_at = Time.now if Setting.user_signup == :needs_approval && !admin
  end

  # Prevent deleting a user unless she has no artifacts left.
  #----------------------------------------------------------------------------
  def has_related_assets?
    sum = %w[Account Campaign Lead Contact Opportunity Comment Task].detect do |asset|
      klass = asset.constantize

      asset != "Comment" && klass.assigned_to(self).exists? || klass.created_by(self).exists?
    end
    !sum.nil?
  end

  # Define class methods
  #----------------------------------------------------------------------------
  class << self
    def can_signup?
      %i[allowed needs_approval].include? Setting.user_signup
    end

    # Overrides Devise sign-in to use either username or email (case-insensitive)
    #----------------------------------------------------------------------------
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:email)
        where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
      end
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_user, self)
end
