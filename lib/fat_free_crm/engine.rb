module FatFreeCRM
  class Engine < ::Rails::Engine
    config.autoload_paths += Dir[root.join("app/models/**")]

    config.to_prepare do
      ActiveRecord::Base.observers = :activity_observer
    end
  end
end