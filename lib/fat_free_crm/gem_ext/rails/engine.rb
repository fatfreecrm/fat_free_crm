# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# Override engine views so that plugin views have higher priority.
Rails::Engine.initializers.detect{|i| i.name == :add_view_paths }.
  instance_variable_set("@block", Proc.new {
    views = paths["app/views"].to_a
    unless views.empty?
      ActiveSupport.on_load(:action_controller){ append_view_path(views) }
      ActiveSupport.on_load(:action_mailer){ append_view_path(views) }
    end
  }
)

# Override I18n load paths so that plugin locales have higher priority.
Rails::Engine.initializers.detect{|i| i.name == :add_locales }.
  instance_variable_set("@block", Proc.new {
    config.i18n.railties_load_path.concat( paths["config/locales"].to_a ).reverse!
  }
)
