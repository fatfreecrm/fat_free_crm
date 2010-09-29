# This extension allows plugins to override various rspec tests
# if they have changed something to break the existing test framework

# Spec overrides should be placed in "vendor/plugins/**/spec/overrides/*.rb",
# and named something like this:  opportunity_spec_override.rb

module FatFreeCRM
  class RSpec   
    include Singleton
    @plugin_spec_replacements = []     
    
    class << self
      attr_accessor :plugin_spec_replacements
      def replace_specs(plugin, &block)
        @plugin = plugin    
        self.instance_eval(&block)
      end
      def replace(params={})
        raise "Please specify a 'describe' key" unless params[:describe]
        raise "Please specify a Proc to replace the block with" unless params[:with]
        params[:describe] = [params[:describe]].flatten
        @plugin_spec_replacements << params
      end
    end
  end
end


# Aliases 'describe' and 'it' methods within RSpec::Core::ExampleGroup,
# ands finds matching specs that need to be overwritten by plugins.
# If a match is found, the plugin will supply a block of test code
# to replace the original block.
RSpec::Core::ExampleGroup.class_eval do
  class << self
    # Helper method to find 'describe' and 'it' spec replacement block matches
    def find_plugin_replacement_block(describe_chain, example_name = nil)
      if replace_spec = FatFreeCRM::RSpec.plugin_spec_replacements.detect{ |replace_hash|
          # If no example_name was given, ignore replace with a specific :it match
          if example_name.blank? and not replace_hash[:it]
            replace_hash[:describe] == describe_chain
          else
            replace_hash[:describe] == describe_chain and replace_hash[:it] == example_name
          end
        }
        return replace_spec[:with]
      end
    end
 
    def nested_describe_chain(hash)
      chain = []
      chain << hash[:description]
      chain += nested_describe_chain(hash[:example_group]) if hash[:example_group]
      return chain
    end
 
    def describe_with_plugin_replacements(*args, &example_group_block)
      describe_chain = metadata ? nested_describe_chain(metadata[:example_group]).reverse : []
      describe_chain << args[0].to_s  # ('describe' param)      
      # Find any plugin spec replacement blocks that match this call to 'describe',
      # and default to the given &example_group_block if none found.
      block = find_plugin_replacement_block(describe_chain) || example_group_block
      describe_without_plugin_replacements(*args, &block)
    end
    alias_method_chain :describe, :plugin_replacements

    def it_with_plugin_replacements(name, &example_group_block)
      describe_chain = nested_describe_chain(metadata[:example_group]).reverse
      # Find any plugin spec replacement blocks that match this call to 'it',
      # and default to the given &example_group_block if none found.
      # Tries to matches the parent and base 'describe', as well as the example name.
      block = find_plugin_replacement_block(describe_chain, name) || example_group_block
      it_without_plugin_replacements(name, &block)
    end
    alias_method_chain :it, :plugin_replacements
  end
end



