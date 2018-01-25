# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
class ConfirmationsController < Devise::ConfirmationsController
  respond_to :html
  append_view_path 'app/views/devise'
end
