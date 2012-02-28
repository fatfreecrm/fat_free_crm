module FatFreeCRM
  module Bushido
    def self.enable_bushido!
      self.load_hooks!
      self.extend_user!
    end

    def self.extend_user!
      puts "Extending the user model"
      User.instance_eval do
        validates_presence_of   :ido_id
        validates_uniqueness_of :ido_id

        before_create :make_admin
      end

      User.class_eval do
        def make_admin
          self.admin = true
        end

        def bushido_extra_attributes(extra_attributes)
          self.first_name = extra_attributes["first_name"]
          self.first_name = extra_attributes["last_name"]
          self.locale     = extra_attributes["locale"]
          self.email      = extra_attributes["email"]
          self.username   = extra_attributes["email"].split("@").first
        end
      end
    end

    def self.load_hooks!
      Dir["#{Dir.pwd}/lib/bushido/**/*.rb"].each { |file| require file }
    end
  end
end

if Bushido::Platform.on_bushido?
  class BushidoRailtie < Rails::Railtie
    
    # Enabling it via this hook means that it'll be reloaded on each
    # request in development mode, so you can make changes in here and
    # it'll be immeidately reflected
    config.to_prepare do
      puts "Enabling Bushido"
      FatFreeCRM::Bushido.enable_bushido!
      puts "Finished enabling Bushido"
    end
  end
end
