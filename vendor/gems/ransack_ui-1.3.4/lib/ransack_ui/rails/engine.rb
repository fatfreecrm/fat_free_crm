require 'ransack_ui/view_helpers'
require 'ransack_ui/controller_helpers'

module RansackUI
  module Rails
    class Engine < ::Rails::Engine
      initializer "ransack_ui.view_helpers" do
        ActionView::Base.send :include, ViewHelpers
      end

      initializer "ransack_ui.controller_helpers" do
        ActionController::Base.send :include, ControllerHelpers
      end

      config.before_configuration do
        # Add images to be precompiled
        ::Rails.application.config.assets.precompile += %w(ransack_ui/delete.png ransack_ui/calendar.png)
      end
    end
  end
end
