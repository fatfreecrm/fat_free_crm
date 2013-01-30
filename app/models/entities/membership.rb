class Membership < ActiveRecord::Base
  belongs_to :contact_group
  belongs_to :contact
  
  has_paper_trail :meta => { :related => :contact }, :ignore => [ :created_at, :updated_at ]
  
  #validates :account_id, :presence => true

end