class Account < ActiveRecord::Base
  belongs_to :user
  has_many :permissions, :as => :asset, :include => :user
  acts_as_paranoid
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id

end
