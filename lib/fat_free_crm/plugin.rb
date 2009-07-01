# Fat Free CRM
# Copyright (C) 2008-2009 by Michael Dvorkin
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

    # Create getters and setters for plugin properties.
    #--------------------------------------------------------------------------
    %w(name description author version).each do |name|
      define_method(name) do |*args|
        args.empty? ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", args.first)
      end
    end
    
    #--------------------------------------------------------------------------
    def initialize(id)
      @id = id
    end

    # Class methods.
    #--------------------------------------------------------------------------
    class << self
      private :new  # For the outside world new plugins can only be created through self.add.

      def register(id, &block)
        plugin = new(id)
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