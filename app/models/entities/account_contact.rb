# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: account_contacts
#
#  id         :integer         not null, primary key
#  account_id :integer
#  contact_id :integer
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

class AccountContact < ActiveRecord::Base
  belongs_to :account
  belongs_to :contact

  has_paper_trail class_name: 'Version', meta: { related: :contact },
                  ignore: [:id, :created_at, :updated_at, :contact_id]

  validates_presence_of :account_id

  ActiveSupport.run_load_hooks(:fat_free_crm_account_contact, self)
end
