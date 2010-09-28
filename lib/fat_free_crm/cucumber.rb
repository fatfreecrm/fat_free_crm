module FatFreeCRM
  
  class Cucumber
    include Singleton
    @expected_failures = []     
    
    class << self
      attr_accessor :expected_failures 
      def expect_failures(plugin, &block)
        @plugin = plugin       
        self.instance_eval(&block)
      end
      
      def skip(file, scenario=nil)
        @expected_failures << [@plugin, file, scenario]
      end
    end
  end
end
