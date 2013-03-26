# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'action_controller'
require 'authlogic'

# Fix bug for default cookie name (use klass_name, instead of guessed_klass_name)
# Pull request pending: https://github.com/binarylogic/authlogic/pull/281
Authlogic::Session::Base.instance_eval do
  def cookie_key(value = nil)
    rw_config(:cookie_key, value, "#{klass_name.underscore}_credentials")
  end
end

