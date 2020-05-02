# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
puts "fat free crm module"
module FatFreeCrm
  class Engine < ::Rails::Engine
    isolate_namespace FatFreeCrm
  end
end
