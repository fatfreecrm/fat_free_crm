# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class List < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :user

  # Parses the controller from the url
  def controller
    (url || "").sub(/^\//,'').split(/\/|\?/).first
  end
  ActiveSupport.run_load_hooks(:fat_free_crm_list, self)
end
