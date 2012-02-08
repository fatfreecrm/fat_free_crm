module ::FatFreeCRM
  class Engine < Rails::Engine
    config.autoload_paths += Dir[root.join("app/models/**")]
    
    initializer "fat_free_crm.init_observers", :before => :load_config_initializers do |app|
      app.config.active_record.observers = :event_observer
    end
  end
end
