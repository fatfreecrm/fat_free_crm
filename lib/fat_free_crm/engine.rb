# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCRM
  class Engine < ::Rails::Engine
    config.autoload_paths += Dir[root.join("app/models/**")] +
                             Dir[root.join("app/controllers/entities")]

    config.to_prepare do
      ActiveRecord::Base.observers = :lead_observer, :opportunity_observer, :task_observer
    end
  end
end
