# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :permissions

  attr_accessible :name, :user_ids

  validates :name, :presence => true, :uniqueness => true

  # TODO: Fix chosen bug that makes this necessary
  def user_ids=(value)
    super value.join.split(',')
  end
end
