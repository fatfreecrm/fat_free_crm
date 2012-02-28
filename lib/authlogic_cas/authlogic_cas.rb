require 'rubycas-client'

module Authlogic
  module Cas

    @@cas_base_url = "http://noshido.com:3000/cas"

    # The login URL of the CAS server.  If undefined, will default based on cas_base_url.
    @@cas_login_url = nil

    # The login URL of the CAS server.  If undefined, will default based on cas_base_url.
    @@cas_logout_url = nil

    # The login URL of the CAS server.  If undefined, will default based on cas_base_url.
    @@cas_validate_url = nil

    # Should devise_cas_authenticatable enable single-sign-out? Requires use of a supported
    # session_store. Currently supports active_record or redis.
    # False by default.
    @@cas_enable_single_sign_out = true

    # What strategy should single sign out use for tracking token->session ID mapping.
    # :rails_cache by default.
    @@cas_single_sign_out_mapping_strategy = :rails_cache

    # Should devise_cas_authenticatable attempt to create new user records for
    # unknown usernames?  True by default.
    @@cas_create_user = true

    # The model attribute used for query conditions. Should be the same as
    # the rubycas-server username_column. :username by default
    @@cas_username_column = :ido_id

    # Name of the parameter passed in the logout query
    @@cas_destination_logout_param_name = nil
    
    mattr_accessor(
      :cas_base_url,
      :authentication_model,
      :actor_model,
      :cas_login_url,
      :cas_logout_url,
      :cas_validate_url,
      :cas_create_user,
      :cas_destination_logout_param_name,
      :cas_username_column,
      :cas_enable_single_sign_out,
      :cas_single_sign_out_mapping_strategy)


    def self.cas_create_user?
      cas_create_user
    end
    
    def self.cas_client
      @@cas_client ||= ::CASClient::Client.new(
        :cas_destination_logout_param_name => @@cas_destination_logout_param_name,
        :cas_base_url => @@cas_base_url,
        :login_url => @@cas_login_url,
        :logout_url => @@cas_logout_url,
        :validate_url => @@cas_validate_url,
        :enable_single_sign_out => @@cas_enable_single_sign_out
        )
    end
  end
end

module Authlogic
  module Cas
    class << self

      def setup_authentication
        define_authentication_method_for Authlogic::Cas.actor_model
        add_controller_actions_for Authlogic::Cas.authentication_model
      end


      def define_authentication_method_for(model)
        model.instance_eval do
          define_singleton_method :authenticate_with_cas_ticket do |ticket|
            ::Authlogic::Cas.cas_client.validate_service_ticket(ticket) unless ticket.has_been_validated?
            return nil if not ticket.is_valid?

            conditions = {::Authlogic::Cas.cas_username_column => ticket.respond_to?(:user) ? ticket.user : ticket.response.user}
            resource   = find(:first, :conditions => conditions)

            if (resource.nil? and ::Authlogic::Cas.cas_create_user?)
              new_user_attributes = ({:persistence_token => ::Authlogic::Random.hex_token})
              resource            = new(conditions.merge(new_user_attributes))
              resource.bushido_on_create if resource.respond_to?(:bushido_on_create)
            end

            return nil if not resource

            if resource.respond_to? :bushido_extra_attributes
              extra_attributes = ticket.respond_to?(:extra_attributes) ? ticket.extra_attributes : ticket.response.extra_attributes
              resource.bushido_extra_attributes(extra_attributes)
            end

            resource.save
            resource
          end

        end
      end

      def add_controller_actions_for(model)
        "#{model.to_s.pluralize}Controller".constantize.instance_eval do
          include ::Authlogic::Cas::ControllerActions::Service
        end
      end
    end
  end
end


module Authlogic
  module Cas
    module ControllerActions
      module Service
        def service
          cas_scope    = ::Authlogic::Cas.actor_model
          ticket       = ticket_from params
          auth_result  = cas_scope.authenticate_with_cas_ticket(ticket)
          
          (redirect_to(root_path, :notice => "Could not authenticate user") && return) if not auth_result

          if ::Authlogic::Cas.cas_enable_single_sign_out
            unique_cas_id = ticket.respond_to?(:user) ? ticket.user : ticket.response.user
            ::Authlogic::Cas::SingleSignOut::Cache.store_unique_cas_id_for_service_ticket(ticket.ticket, unique_cas_id)
          end

          user_session = Authlogic::Cas.authentication_model.new(auth_result)
          if user_session.save
            redirect_to(root_path)
          else
            redirect_to(root_path, :notice => "Could not login. Try again please.")
          end
        end

        def single_signout
          if ::Authlogic::Cas.cas_enable_single_sign_out
            service_ticket = read_service_ticket_name

            if service_ticket
              logger.info "Intercepted single-sign-out request for CAS session #{service_ticket}."
              ido_id = ::Authlogic::Cas::SingleSignOut::Cache.find_unique_cas_id_by_service_ticket(service_ticket)
              update_persistence_token_for(ido_id)
            end
          else
            logger.warn "Ignoring CAS single-sign-out request as feature is not currently enabled."
          end

          render :nothing => true
        end

        # protected

        def update_persistence_token_for(ido_id)
          user = User.send("find_by_#{::Authlogic::Cas.cas_username_column.to_s}", ido_id)
          user.update_attribute(:persistence_token, ::Authlogic::Random.hex_token) if user
        end
        
        def ticket_from(controller_params)
          ticket_name = controller_params[:ticket]
          return nil unless ticket_name

          service_url = bushido_service_url
          if ticket_name =~ /^PT-/
            ::CASClient::ProxyTicket.new(ticket_name, service_url, controller_params[:renew])
          else
            ::CASClient::ServiceTicket.new(ticket_name, service_url, controller_params[:renew])
          end
        end
        
        def read_service_ticket_name
          if request.headers['CONTENT_TYPE'] =~ %r{^multipart/}
            false
          elsif request.post? && params['logoutRequest'] =~
              %r{^<samlp:LogoutRequest.*?<samlp:SessionIndex>(.*)</samlp:SessionIndex>}m
            $~[1]
          else
            false
          end
        end
      end

    end
  end
end


module Authlogic
  module Cas
    module ControllerActions
      module Session

        def new_bushido_session
          puts "Trying new user session"
          redirect_to(cas_login_url) unless returning_from_cas?
        end

        def destroy_bushido_session
          puts "AUTH MODEL: #{::Authlogic::Cas.authentication_model.inspect}"
          @user_session = ::Authlogic::Cas.authentication_model.find
          @user_session.destroy
          redirect_to ::Authlogic::Cas.cas_client.logout_url
        end

        # protected

        def returning_from_cas?
          puts "REFERER: #{request.referer.inspect} #{params[:ticket].inspect}"
          puts "RETURNING FROM CAS: #{(params[:ticket] || request.referer =~ /^#{::Authlogic::Cas.cas_client.cas_base_url}/).inspect}"
          params[:ticket] || request.referer =~ /^#{::Authlogic::Cas.cas_client.cas_base_url}/
        end


        def cas_login_url
          login_url_from_cas_client = ::Authlogic::Cas.cas_client.add_service_to_login_url(bushido_service_url)
          redirect_url = ""# "&redirect=#{cas_return_to_url}"
          puts "redirecting to #{login_url_from_cas_client}#{redirect_url}"
          return "#{login_url_from_cas_client}#{redirect_url}"
        end

      end
    end
  end
end

