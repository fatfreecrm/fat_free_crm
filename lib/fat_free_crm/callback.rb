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
