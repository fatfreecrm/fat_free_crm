# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: permissions
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  asset_id   :integer
#  asset_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Permission < ActiveRecord::Base
  belongs_to :user, optional: true
  belongs_to :group, optional: true
  belongs_to :asset, polymorphic: true, optional: true

  validates_presence_of :user_id, unless: :group_id?
  validates_presence_of :group_id, unless: :user_id?

  validates_uniqueness_of :user_id, scope: %i[group_id asset_id asset_type]

  ActiveSupport.run_load_hooks(:fat_free_crm_permission, self)
end
