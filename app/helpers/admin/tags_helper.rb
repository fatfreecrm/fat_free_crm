# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Admin::TagsHelper
  def link_to_confirm(tag)
    link_to(t(:delete) + "?", confirm_admin_tag_path(tag), method: :get, remote: true)
  end
end
