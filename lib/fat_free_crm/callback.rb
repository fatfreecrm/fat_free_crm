module FatFreeCRM
  module Callback
    @@classes   = []  # Classes that inherit from FatFreeCRM::Callback::Base.
    @@responder = {}  # Class instances that respond to (i.e. implement) hook methods.

    # Adds a class inherited from from FatFreeCRM::Callback::Base.
    #------------------------------------------------------------------------------
    def self.add(klass)
      @@classes << klass
    end

    # Finds class instance that responds to given method.
    #------------------------------------------------------------------------------
    def self.responder(method)
      @@responder[method] ||= @@classes.map { |klass| klass.instance }.select { |instance| instance.respond_to?(method) }
    end

    # Invokes hook method(s) and captures the output.
    #------------------------------------------------------------------------------
    def self.hook(method, context = {} )
      response = ""
      responder(method).each do |m|
        response << m.send(method, context).to_s
      end
      response
    end

    #------------------------------------------------------------------------------
    class Base
      include Singleton

      def self.inherited(child)
        FatFreeCRM::Callback.add(child)
        super
      end
      
    end # class Base

  end # module Callback
end # module FatFreeCRM
