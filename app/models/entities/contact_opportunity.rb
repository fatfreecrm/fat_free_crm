# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: contact_opportunities
#
#  id             :integer         not null, primary key
#  contact_id     :integer
#  opportunity_id :integer
#  role           :string(32)
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class ContactOpportunity < ActiveRecord::Base
  belongs_to :contact
  belongs_to :opportunity
  validates_presence_of :contact_id, :opportunity_id

  # has_paper_trail :class_name => 'Version'

  ActiveSupport.run_load_hooks(:fat_free_crm_contact_opportunity, self)
end
