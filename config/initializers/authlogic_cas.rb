require_relative "#{Rails.root}/lib/authlogic_cas/authlogic_cas.rb"
require_relative "#{Rails.root}/lib/authlogic_cas/rails_cache.rb"


Authlogic::Cas.actor_model = User
Authlogic::Cas.authentication_model = Authentication
Authlogic::Cas.setup_authentication

# ActionDispatch::Routing::Mapper.class_eval do
#   def authlogic_bushido_routes_for(model)
#     controller_name = model.to_s
#     match "/#{controller_name}/service" => "#{controller_name}#service", :via => :get
#     match "/#{controller_name}/service" => "#{controller_name}#single_signout", :via => :post, :as => "single_signout"
#   end
# end


class User < ActiveRecord::Base
  def bushido_extra_attributes(extra_attributes)
    self.first_name = extra_attributes["first_name"]
    self.first_name = extra_attributes["last_name"]
    self.locale     = extra_attributes["locale"]
    self.email      = extra_attributes["email"]
    self.username   = extra_attributes["email"].split("@").first
  end

  def bushido_on_create
    self.update_attribute(:admin, true)
  end
end

class BushidoClientController < ApplicationController
  include ::Authlogic::Cas::ControllerActions::Service
end

class AuthenticationsController < ApplicationController
  include ::Authlogic::Cas::ControllerActions::Session
end
