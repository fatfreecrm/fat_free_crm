# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: fields
#
#  id             :integer         not null, primary key
#  type           :string(255)
#  field_group_id :integer
#  position       :integer
#  name           :string(64)
#  label          :string(128)
#  hint           :string(255)
#  placeholder    :string(255)
#  as             :string(32)
#  collection     :text
#  disabled       :boolean
#  required       :boolean
#  minlength      :integer
#  maxlength      :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class CoreField < Field
  # Some CoreField attributes should be read-only
  attr_readonly :name, :as, :collection
  before_destroy :error_on_destroy

  def error_on_destroy
    errors.add_to_base "Core fields cannot be deleted."
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_core_field, self)
end
