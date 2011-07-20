# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
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
      @@responder[method] ||= @@classes.map { |klass| klass.instance }.select { |instance| instance.respond_to?(method) }
    end
    # Invokes the hook named :method and captures its output. The hook returns:
    # - empty array if no hook with this name was detected.
    # - array with single item returned by the hook.
    # - array with multiple items returned by the hook chain.
    #--------------------------------------------------------------------------
    def self.hook(method, caller, context = {})
      responder(method).map do |m|
        m.send(method, caller, context)
      end
    end


    #                             [View] Hooks
    # -----------------------------------------------------------------------------

    # Find class instances that contain operations for the given view hook.
    #------------------------------------------------------------------------------
    def self.view_responder(method)
      @@responder[method] ||= @@classes.map { |klass| klass.instance }.select { |instance| instance.class.view_hooks[method] }
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
      view_responder(hook).inject(Hash.new([])) do |response, instance|
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
          @view_hooks[hook] += [{:proc => proc,
                                 :position => position}]
        end

        def insert_before(hook, &block); add_view_hook(hook, block,        :before);  end
        def insert_after(hook, &block);  add_view_hook(hook, block,        :after);   end
        def replace(hook, &block);       add_view_hook(hook, block,        :replace); end
        def remove(hook);                add_view_hook(hook, Proc.new{""}, :replace); end
      end
    end # class Base

    # This makes it possible to call hook() without FatFreeCRM::Callback prefix.
    # Returns stringified data when called from within templates, and the actual
    # data otherwise.
    #--------------------------------------------------------------------------
    module Helper
      def hook(method, caller, context = {}, &block)
        is_view_hook = caller.is_haml?

        # If a block was given, hooks are able to replace, append or prepend view content.
        if block_given? and is_view_hook
          hooks = FatFreeCRM::Callback.view_hook(method, caller, context)
          # Add content to the view in the following order:
          # -- before
          # -- replace || original block
          # -- after
          view_data = []
          hooks[:before].each{|data| view_data << data }
          # Only render the original view block if there are no pending :replace operations
          if hooks[:replace].empty?
            view_data << capture(&block)
          else
            hooks[:replace].each{|data| view_data << data }
          end
          hooks[:after].each{|data| view_data << data }
          
          view_data.join.html_safe

        else
          # Hooks called without blocks are either controller or legacy view hooks
          data = FatFreeCRM::Callback.hook(method, caller, context)
          is_view_hook ? data.join.html_safe : data
        end
      end
    end # module Helper

  end # module Callback
end # module FatFreeCRM
