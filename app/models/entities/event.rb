class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many :tasks, :as => :asset, :dependent => :destroy#, :order => 'created_at DESC'
  has_many    :emails, :as => :mediator
  belongs_to :contact_group
  has_many :event_instances, :dependent => :destroy
  
  serialize :subscribed_users, Set

  scope :created_by, lambda { |user| { :conditions => [ "user_id = ?", user.id ] } }
  scope :assigned_to, lambda { |user| { :conditions => ["assigned_to = ?", user.id ] } }

  scope :text_search, lambda { |query|
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    where('upper(name) LIKE upper(?)', "%#{query}%")
  }

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail :ignore => [ :subscribed_users ]
  has_fields
  exportable
  sortable :by => [ "name ASC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  validates_presence_of :name, :message => :missing_name
  validate :users_for_shared_access

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20 ; end
  def self.outline ; "long" ; end

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

  private

  # Make sure at least one user has been selected if the campaign is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_campaign) if self[:access] == "Shared" && !self.permissions.any?
  end

end