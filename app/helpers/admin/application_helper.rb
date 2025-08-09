# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Admin::ApplicationHelper
  #----------------------------------------------------------------------------
  def link_to_confirm_delete(model)
    link_to(t(:yes_button),
            url_for([:admin, model]),
            method:  :delete,
            remote:  true)
  end
end
