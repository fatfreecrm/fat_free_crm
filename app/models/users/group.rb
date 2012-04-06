class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :permissions

  attr_accessible :name

  validates_presence_of :name
end
