# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCRM
  module Callback
    @@classes   = []  # Classes that inherit from FatFreeCRM::Callback::Base.
    @@responder = {}  # Class instances that respond to (i.e. implement) hook methods.
    # Also includes class instances that implement a
    # set of view hook operations (insert_after, replace, etc).

    # Adds a class inherited from from FatFreeCRM::Callback::Base.
    #--------------------------------------------------------------------------
    def self.add(klass)
      @@classes << klass
    end

    #                     [Controller] and [Legacy View] Hooks
    # -----------------------------------------------------------------------------

    # Finds class instance that responds to given method.
    #------------------------------------------------------------------------------
    def self.responder(method)
      @@responder[method] ||= @@classes.map(&:instance).select { |instance| instance.respond_to?(method) }
    end

    # Invokes the hook named :method and captures its output.
    #--------------------------------------------------------------------------
    def self.hook(method, caller, context = {})
      str = "".html_safe
      responder(method).map do |m|
        str << m.send(method, caller, context) if m.respond_to?(method)
      end
      str
    end

    #                             [View] Hooks
    # -----------------------------------------------------------------------------

    # Find class instances that contain operations for the given view hook.
    #------------------------------------------------------------------------------
    def self.view_responder(method)
      @@responder[method] ||= @@classes.map(&:instance).select { |instance| instance.class.view_hooks[method] }
    end

    # Invokes the view hook Proc stored under :hook and captures its output.
    # => Instead of defining methods on the class, view hooks are
    #    stored as Procs in a hash. This allows the same hook to be manipulated in
    #    multiple ways from within a single Callback subclass.
    # The hook returns:
    # - empty hash if no hook with this name was detected.
    # - a hash of arrays containing Procs and positions to insert content.
    #--------------------------------------------------------------------------
    def self.view_hook(hook, caller, context = {})
      view_responder(hook).each_with_object(Hash.new([])) do |instance, response|
        # Process each operation within each view hook, storing the data in a hash.
        instance.class.view_hooks[hook].each do |op|
          response[op[:position]] += [op[:proc].call(caller, context)]
        end
        response
      end
    end

    #--------------------------------------------------------------------------
    class Base
      include Singleton
      def self.inherited(child)
        FatFreeCRM::Callback.add(child)
        # Positioning hash to determine where content is placed.
        child.class_eval do
          @view_hooks = Hash.new([])
        end
        super
      end

      class << self
        attr_accessor :view_hooks

        def add_view_hook(hook, proc, position)
          @view_hooks[hook] += [{ proc: proc,
                                  position: position }]
        end

        def insert_before(hook, &block)
          add_view_hook(hook, block,        :before)
        end

        def insert_after(hook, &block)
          add_view_hook(hook, block,        :after)
        end

        def replace(hook, &block)
          add_view_hook(hook, block,        :replace)
        end

        def remove(hook)
          add_view_hook(hook, proc { "" }, :replace)
        end
      end
    end

    # This makes it possible to call hook() without FatFreeCRM::Callback prefix.
    # Returns stringified data when called from within templates, and the actual
    # data otherwise.
    #--------------------------------------------------------------------------
    module Helper
      def hook(method, caller, context = {}, &block)
        is_view_hook = caller.is_haml?

        # If a block was given, hooks are able to replace, append or prepend view content.
        if is_view_hook
          hooks = FatFreeCRM::Callback.view_hook(method, caller, context)
          # Add content to the view in the following order:
          # -- before
          # -- replace || original block
          # -- after
          view_data = "".html_safe
          hooks[:before].each { |data| view_data << data }
          # Only render the original view block if there are no pending :replace operations
          if hooks[:replace].empty?
            view_data << if block_given?
                           capture(&block)
                         else
                           # legacy view hooks
                           FatFreeCRM::Callback.hook(method, caller, context)
              end
          else
            hooks[:replace].each { |data| view_data << data }
          end
          hooks[:after].each { |data| view_data << data }

          view_data

        else
          # Hooks called without blocks are either controller or legacy view hooks
          FatFreeCRM::Callback.hook(method, caller, context)
        end
      end
    end
  end
end

ActionView::Base.include FatFreeCRM::Callback::Helper
ActionController::Base.include FatFreeCRM::Callback::Helper
