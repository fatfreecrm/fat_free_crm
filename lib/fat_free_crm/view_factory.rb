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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module FatFreeCRM

  # A view factory keeps track of views and the contexts in which they are available.
  #----------------------------------------------------------------------------
  #
  # The context that a view is available for is defined by 'controllers' and 'actions'
  #   controllers => ['contacts'] means that the view is available when the contacts controller is used
  #   actions => [:index, show] means that the view is available for search listings AND individual records
  #   template => 'contacts/index_full' is the partial that is rendered for this view
  # Icon is optional. If specified, it will be passed to asset_path.
  #
  class ViewFactory
  
    include Comparable

    @@views = []
    attr_accessor :id, :name, :icon, :title, :controllers, :actions, :template

    # Class methods
    #----------------------------------------------------------------------------
    class << self
    
      # Register with the view factory
      #----------------------------------------------------------------------------
      def register(view)
        @@views << view unless @@views.map(&:id).include?(view.id)
      end
      
      # Return views that are available based on context
      #----------------------------------------------------------------------------
      def views_for(options = {})
        controller = options[:controller]
        action = options[:action]
        name = options[:name] #optional
        @@views.select do |view|
          view.controllers.include?(controller) and view.actions.include?(action) and (name.present? ? view.name == name : true)
        end
      end
      
      # Return template name of the current view
      # pass in options[:name] to specify view name
      #----------------------------------------------------------------------------
      def template_for_current_view(options = {})
        view = views_for(options).first
        view && view.template
      end

    end

    # Instance methods
    #----------------------------------------------------------------------------
    def initialize(options = {})
      self.name = options[:name]
      self.title = options[:title]
      self.icon = options[:icon] # optional
      self.controllers = options[:controllers] || []
      self.actions = options[:actions] || []
      self.template = options[:template]
      self.id = generate_id
      self.class.register(self)
    end

    # Define view equivalence. They are the same if they have the same id.
    #----------------------------------------------------------------------------
    def <=>(other)
      id <=> other.id
    end

    private
    
    # This defines what it means for one view to be different to another
    #----------------------------------------------------------------------------
    def generate_id
       [name, controllers.sort, actions.sort].flatten.map(&:to_s).map(&:underscore).join('_')
    end

  end
end
