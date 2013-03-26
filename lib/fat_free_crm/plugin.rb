# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
Rails::Plugin.class_eval do
  def initializer
    #~ ActiveSupport::Deprecation.warn "Rails::Plugin initializer is depricated use Railties instead"
    if Rails.env.development?
      config.cache_classes = false # Tell Rails not to reload core classes when developing Fat Free CRM plugin.
    end
    self
  end
end

module FatFreeCRM
  class Plugin
    @@list = {} # List of added plugins.

    #--------------------------------------------------------------------------
    def initialize(id, initializer)
      @id, @initializer = id, initializer
    end

    # Create getters and setters for plugin properties.
    #--------------------------------------------------------------------------
    %w(name description author version).each do |name|
      define_method(name) do |*args|
        args.empty? ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", args.first)
      end
    end
    alias :authors :author

    # Preload other plugins that are required by the plugin being loaded.
    #--------------------------------------------------------------------------
    def dependencies(*plugins)
      plugins.each do |name|
        plugin_path = File.join(Rails.root, 'vendor/plugins', name.to_s)
        require File.directory?(plugin_path) ? File.join(plugin_path, 'init') : name.to_s
      end
    end

    # Define custom tab. See [crm_sample_tabs] plugin for usage examples.
    #   tab(:main | :admin, { :text => ..., :url => ... })
    # or
    #   tab(:main | :admin) { |tabs| ... }
    #--------------------------------------------------------------------------
    def tab(main_or_admin, options = nil)
      if main_or_admin.is_a?(Hash)    # Make it possible to omit first parameter...
        options = main_or_admin.dup   # ...and use :main as default.
        main_or_admin = :main
      end
      if Setting.database_and_table_exists?
        tabs = FatFreeCRM::Tabs.send(main_or_admin)
        if tabs                         # Might be nil when running rake task (ex: rake ffcrm:setup).
          if block_given?
            yield tabs
          else
            tabs << options if options
          end
        end
      end
    end

    # Class methods.
    #--------------------------------------------------------------------------
    class << self
      private :new  # For the outside world new plugins can only be created through self.register.

      def register(id, initializer = nil, &block)
        unless @@list.include?(id)
          plugin = new(id, initializer)
          plugin.instance_eval(&block)            # Grab plugin properties.
          plugin.name(id.to_s) unless plugin.name # Set default name if the name property was missing.

          @@list[id] = plugin
        end
      end
      alias_method :<<, :register

      #------------------------------------------------------------------------
      def list
        @@list.values
      end

      def list_ids
        @@list.keys
      end

    end

  end # class Plugin
end # module FatFreeCRM

