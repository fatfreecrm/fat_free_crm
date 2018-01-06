# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: account_opportunities
#
#  id             :integer         not null, primary key
#  account_id     :integer
#  opportunity_id :integer
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class AccountOpportunity < ActiveRecord::Base
  belongs_to :account, counter_cache: :opportunities_count
  belongs_to :opportunity
  validates_presence_of :account_id, :opportunity_id

  has_paper_trail class_name: 'Version'

  ActiveSupport.run_load_hooks(:fat_free_crm_account_opportunity, self)
end
