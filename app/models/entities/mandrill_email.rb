class MandrillEmail < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many :tasks, :as => :asset, :dependent => :destroy#, :order => 'created_at DESC'
  has_many :attached_files, :dependent => :destroy
  #has_many    :emails, :as => :mediator
  
  accepts_nested_attributes_for :attached_files
  serialize :subscribed_users, Set
  
  attr_accessor :scheduled_date, :scheduled_time
  
  scope :created_by, lambda { |user| { :conditions => [ "user_id = ?", user.id ] } }
  scope :assigned_to, lambda { |user| { :conditions => ["assigned_to = ?", user.id ] } }
  scope :state, lambda { |filters|
    where('category IN (?)' + (filters.delete('other') ? ' OR category IS NULL ' : ''), filters)
  }
  scope :text_search, lambda { |query|
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    where('upper(name) LIKE upper(?)', "%#{query}%")
  }

  uses_user_permissions
  #acts_as_commentable
  #uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail :ignore => [ :subscribed_users ]
  has_fields
  exportable
  sortable :by => [ "name ASC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  validates_presence_of :name, :message => :missing_name
  #validates_presence_of :message_subject, :message => :missing_subject
  #validates_presence_of :from_address, :message => :missing_sender
  
  validate :users_for_shared_access
  #validate :valid_time_start
  before_save :nullify_blank_category
  before_update :set_datetime
  
  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20 ; end
  def self.outline ; "long" ; end
  
    # Backend handler for [Create New Contact] form (see contact/create).
  #----------------------------------------------------------------------------
  def save_with_permissions(params)
    #self.contacts << Contact.find(params[:related_contact][:contact]) unless params[:related_contact][:contact].blank?
    #self.contact_group = ContactGroup.new(:contacts => contact, :contact_group => self) unless contact.id.blank?
    #self.opportunities << Opportunity.find(params[:opportunity]) unless params[:opportunity].blank?
    self.access = params[:mandrill_email][:access] if params[:mandrill_email][:access]
    self.save
  end

  # Backend handler for [Update Contact] form (see contact/update).
  #----------------------------------------------------------------------------
  def update_with_permissions(params)
    # Must set access before user_ids, because user_ids= method depends on access value.
    self.access = params[:mandrill_email][:access] if params[:mandrill_email][:access]
    self.attributes = params[:mandrill_email]
    self.save
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

  def scheduled_at_time
    self.scheduled_at.strftime('%I:%M %p') unless self.scheduled_at.blank?
  end
  
  def scheduled_at_date
    self.scheduled_at.strftime('%d/%m/%Y') unless self.scheduled_at.blank?
  end

  private
  
  #----------------------------------------------------------------------------
  def set_datetime
    self.scheduled_at = parse_scheduled_date_start unless self.scheduled_date.nil? or self.scheduled_time.nil?
  end

  #----------------------------------------------------------------------------
  def valid_time_start
    parse_scheduled_date_start
  rescue ArgumentError
    errors.add(:scheduled_date, :invalid_date)
  end
  
  #----------------------------------------------------------------------------
  def parse_scheduled_date_start
    # always in 2012-10-28 06:28 format regardless of language
    Time.parse(self.scheduled_date + " " + self.scheduled_time)
  end

  # Make sure at least one user has been selected if the campaign is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_mandrill_email) if self[:access] == "Shared" && !self.permissions.any?
  end
  
  def nullify_blank_category
    self.category = nil if self.category.blank?
  end

end