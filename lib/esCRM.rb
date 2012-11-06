Rails.configuration.to_prepare do
  require_dependency 'contact'
  require_dependency 'contact_mod'
  # Extend :account model to add :lists association.
  Contact.send(:include, ContactMods)
  # Extend account controller
  #AccountsController.send(:include, AccountsControllerExtensions)
  # Make lists observable. <--- This appear to work only in production mode
  #ActivityObserver.instance.send :add_observer!, List

  # Add :lists plugin helpers.
  #ActionView::Base.send(:include, ListsHelper)
  #ActionView::Base.send(:include, AccountListsHelper)
  #ActionView::Base.send(:include, StandingOrdersHelper)
  #ActionView::Base.send(:include, AccountsHelper)
  #ActionView::Base.send(:include, AdditionalDiscountsHelper)
  #ActionView::Base.send(:include, EquipmentEntriesHelper)

end

# NOTE: for some misterious reason the following doesn't work within Dispatcher block,
# so the :tabs override works in production mode only. (Or in development mode with 
# config.cache_classes = true.)

# Make the lists commentable.
#CommentsController::COMMENTABLE = CommentsController::COMMENTABLE + %w(list_id)
