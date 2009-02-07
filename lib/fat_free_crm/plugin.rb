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