module FatFreeCRM
  module Callback
    @@classes   = []  # Classes that inherit from FatFreeCRM::Callback::Base.
    @@responder = {}  # Class instances that respond to (i.e. implement) hook methods.

    # Adds a class inherited from from FatFreeCRM::Callback::Base.
    #--------------------------------------------------------------------------
    def self.add(klass)
      @@classes << klass
    end

    # Finds class instance that responds to given method.
    #------------------------------------------------------------------------------
    def self.responder(method)
      @@responder[method] ||= @@classes.map { |klass| klass.instance }.select { |instance| instance.respond_to?(method) }
    end

    # Invokes hook method(s) and captures the output.
    #--------------------------------------------------------------------------
    def self.hook(method, caller, context = {})
      response = ""
      responder(method).each do |m|
        response << m.send(method, caller, context).to_s
      end
      response
    end

    #--------------------------------------------------------------------------
    class Base
      include Singleton

      def self.inherited(child)
        FatFreeCRM::Callback.add(child)
        super
      end
      
    end # class Base

    # This makes it possible to call hook() without FatFreeCRM::Callback prefix.
    #--------------------------------------------------------------------------
    module Helper
      def hook(method, caller, context = {})
        FatFreeCRM::Callback.hook(method, caller, context)
      end
    end # module Helper

  end # module Callback
end # module FatFreeCRM

ActionView::Base.send(:include, FatFreeCRM::Callback::Helper)
ActionController::Base.send(:include, FatFreeCRM::Callback::Helper)
