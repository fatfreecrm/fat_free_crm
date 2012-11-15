class Event < ActiveRecord::Base
  attr_accessor :calendar_start_date, :calendar_end_date, :calendar_start_time, :calendar_end_time
  
  belongs_to :user
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many :tasks, :as => :asset, :dependent => :destroy#, :order => 'created_at DESC'
  has_many    :emails, :as => :mediator
  belongs_to :contact_group
  has_many :attendances, :dependent => :destroy
  has_many :contacts, :through => :attendances
  
  serialize :subscribed_users, Set

  scope :created_by, lambda { |user| { :conditions => [ "user_id = ?", user.id ] } }
  scope :assigned_to, lambda { |user| { :conditions => ["assigned_to = ?", user.id ] } }
  scope :state, lambda { |filters|
    where('category IN (?)' + (filters.delete('other') ? ' OR category IS NULL' : ''), filters)
  }
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
  validates_presence_of :calendar_start, :calendar_end, :unless => lambda { self.calendar_start.nil? & self.calendar_end.nil?}
  validate :users_for_shared_access
  validate :specific_time_start, :unless => lambda { !self.calendar_start.nil? }
  validate :specific_time_end,  :unless => lambda { !self.calendar_end.nil? }
  
  before_save :nullify_blank_category
  before_create :set_datetime
  before_update :set_datetime

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
  
  def starts_at_time
    self.starts_at.strftime('%I:%m%p') unless self.starts_at.blank?
  end

  def ends_at_time
    self.ends_at.strftime('%I:%m%p') unless self.ends_at.blank?
  end
  
  def starts_at_date
    self.starts_at.strftime('%d/%m/%Y') unless self.starts_at.blank?
  end
  
  def ends_at_date
    self.ends_at.strftime('%d/%m/%Y') unless self.ends_at.blank?
  end

  private
  
  #----------------------------------------------------------------------------
  def set_datetime
    self.starts_at = self.calendar_start.blank? ? nil : parse_calendar_date_start
    self.ends_at = self.calendar_end.blank? ? nil : parse_calendar_date_end

  end

  #----------------------------------------------------------------------------
  def specific_time_start
    parse_calendar_date_start
  rescue ArgumentError
    errors.add(:calendar_start, :invalid_date)
  end
  
  #----------------------------------------------------------------------------
  def specific_time_end
    parse_calendar_date_end
  rescue ArgumentError
    errors.add(:calendar_end, :invalid_date)
  end
  
  #----------------------------------------------------------------------------
  def parse_calendar_date_start
    # always in 2012-10-28 06:28 format regardless of language
    Time.parse(self.calendar_start)
  end
  
  #----------------------------------------------------------------------------
  def parse_calendar_date_end
    # always in 2012-10-28 06:28 format regardless of language
    Time.parse(self.calendar_end)
  end
  
  # Make sure at least one user has been selected if the campaign is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_campaign) if self[:access] == "Shared" && !self.permissions.any?
  end
  
  def nullify_blank_category
    self.category = nil if self.category.blank?
  end

end