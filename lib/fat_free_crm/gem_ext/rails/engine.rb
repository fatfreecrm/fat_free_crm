# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# Override engine views so that plugin views have higher priority.
Rails::Engine.initializers.detect { |i| i.name == :add_view_paths }
             .instance_variable_set("@block", proc do
                                                views = paths["app/views"].to_a
                                                unless views.empty?
                                                  ActiveSupport.on_load(:action_controller) { append_view_path(views) }
                                                  ActiveSupport.on_load(:action_mailer) { append_view_path(views) }
                                                end
                                              end)
