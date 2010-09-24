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

    # Invokes the hook named :method and captures its output. The hook returns:
    # - empty array if no hook with this name was detected.
    # - array with single item returned by the hook.
    # - array with multiple items returned by the hook chain.
    #--------------------------------------------------------------------------
    def self.hook(method, caller, context = {})
      responder(method).inject(Hash.new([])) do |response, m|
        response[m.class.positions[method]] += [m.send(method, caller, context)]
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
          @positions = Hash.new(:after)
        end
        super
      end

      class << self
        attr_accessor :positions

        def insert_before(hook, &block)
          define_method hook, &block
          @positions[hook] = :before
        end
        def insert_after(hook, &block)
          define_method hook, &block
          @positions[hook] = :after
        end
        def replace(hook, &block)
          define_method hook, &block
          @positions[hook] = :replace
        end
        def remove(hook)
          define_method hook, Proc.new{""}
          @positions[hook] = :replace
        end
      end
      
    end # class Base

    # This makes it possible to call hook() without FatFreeCRM::Callback prefix.
    # Returns stringified data when called from within templates, and the actual
    # data otherwise.
    #--------------------------------------------------------------------------
    module Helper
      def hook(method, caller, context = {}, &block)
        is_view_hook = caller.class.to_s.start_with?("ActionView")

        # If a block was given, hooks can choose to replace, append or prepend view content.
        if block and is_view_hook
          hook_hash = FatFreeCRM::Callback.hook(method, caller, context)
          # Add content to the view with the following logic:
          # -- before
          # -- replace || original block
          # -- after
          view_data = ""
          hook_hash[:before].each{|data| view_data << data }
          # Only render the original view block if there are no :replace operations
          if hook_hash[:replace].empty?
            view_data << capture(&block)
          else
            hook_hash[:replace].each{|data| view_data << data }
          end
          hook_hash[:after].each{|data| view_data << data }
          view_data

        # Else, if no was block given.. (for backwards compatibility with existing hooks)
        else
          # All legacy hooks will have data stored in the :after key.
          data = FatFreeCRM::Callback.hook(method, caller, context)[:after]
          is_view_hook ? data.join : data
        end
      end
    end # module Helper

  end # module Callback
end # module FatFreeCRM
