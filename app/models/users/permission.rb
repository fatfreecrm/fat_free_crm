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
  belongs_to :user
  belongs_to :group
  belongs_to :asset, :polymorphic => true

  validates_presence_of :user_id, :unless => :group_id?
  validates_presence_of :group_id, :unless => :user_id?
end

