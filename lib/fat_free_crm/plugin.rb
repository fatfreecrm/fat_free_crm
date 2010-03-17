# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

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
      plugin_path = @initializer.configuration.plugin_paths.first
      plugins.each do |name|
        plugin = Rails::Plugin.new("#{plugin_path}/#{name}")
        plugin.load(@initializer)
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
      tabs = FatFreeCRM::Tabs.send(main_or_admin)
      if tabs                         # Might be nil when running rake task (ex: rake crm:setup).
        if block_given?
          yield tabs
        else
          tabs << options if options
        end
      end
    end

    # Class methods.
    #--------------------------------------------------------------------------
    class << self
      private :new  # For the outside world new plugins can only be created through self.register.

      def register(id, initializer = nil, &block)
        if initializer && ENV['RAILS_ENV'] == "development"
          initializer.configuration.cache_classes = true # Tell Rails not to reload core classes when developing Fat Free CRM plugin.
        end
        plugin = new(id, initializer)
        plugin.instance_eval(&block)            # Grab plugin properties.
        plugin.name(id.to_s) unless plugin.name # Set default name if the name property was missing.
        @@list[id] = plugin
      end
      alias_method :<<, :register

      #------------------------------------------------------------------------
      def list
        @@list.values
      end

    end

  end # class Plugin
end # module FatFreeCRM