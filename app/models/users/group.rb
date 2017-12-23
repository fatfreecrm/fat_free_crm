# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :permissions

  validates :name, presence: true, uniqueness: true

  ActiveSupport.run_load_hooks(:fat_free_crm_group, self)
end
