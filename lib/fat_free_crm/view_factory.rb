# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
        name = options[:name] # optional
        @@views.select do |view|
          view.controllers.include?(controller) && view.actions.include?(action) && (name.present? ? view.name == name : true)
        end
      end

      # Return template name of the current view
      # pass in options[:name] to specify view name
      #----------------------------------------------------------------------------
      def template_for_current_view(options = {})
        view = views_for(options).first
        view&.template
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

    ActiveSupport.run_load_hooks(:fat_free_crm_view_factory, self)
  end
end
