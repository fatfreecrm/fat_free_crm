class AttachedFile < ActiveRecord::Base
  belongs_to :mandrill_email
  has_attached_file :attached_file
  attr_protected :attached_file_file_name, :attached_file_content_type, :attached_file_size
  
  validates_format_of(:attached_file_file_name, :with => %r{\.(pdf)$}i)
end