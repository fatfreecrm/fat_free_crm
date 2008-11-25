module Spec
  module Rails
    module Example
      class FunctionalExampleGroup < RailsExampleGroup
        include ActionController::TestProcess
        include ActionController::Assertions

        attr_reader :request, :response
        before(:each) do
          @controller_class = Object.path2class @controller_class_name
          raise "Can't determine controller class for #{@controller_class_name}" if @controller_class.nil?

          @controller = @controller_class.new
          @request = ActionController::TestRequest.new
          @response = ActionController::TestResponse.new
          @response.session = @request.session
        end

        def params
          request.parameters
        end

        def flash
          response.flash
        end

        def session
          response.session
        end
        
        # Overrides the <tt>cookies()</tt> method in
        # ActionController::TestResponseBehaviour, returning a proxy that
        # accesses the requests cookies when setting a cookie and the
        # responses cookies when reading one. This allows you to set and read
        # cookies in examples using the same API with which you set and read
        # them in controllers.
        #
        # == Examples (Rails >= 1.2.6)
        #
        #   cookies[:user_id] = '1234'
        #   get :index
        #   assigns[:user].id.should == '1234'
        #
        #   post :login
        #   cookies[:login].expires.should == 1.week.from_now
        #
        # == Examples (Rails >= 2.0.0 only)
        #
        #   cookies[:user_id] = {:value => '1234', :expires => 1.minute.ago}
        #   get :index
        #   response.should be_redirect
        def cookies
          @cookies ||= Spec::Rails::Example::CookiesProxy.new(self)
        end
        
        alias_method :orig_assigns, :assigns

        # :call-seq:
        #   assigns()
        #
        # Hash of instance variables to values that are made available to
        # views. == Examples
        #
        #   #in thing_controller.rb
        #   def new
        #     @thing = Thing.new
        #   end
        #
        #   #in thing_controller_spec
        #   get 'new'
        #   assigns[:registration].should == Thing.new
        #--
        # NOTE - Even though docs only use assigns[:key] format, this supports
        # assigns(:key) in order to avoid breaking old specs.
        #++
        def assigns(key = nil)
          if key.nil?
            _assigns_hash_proxy
          else
            _assigns_hash_proxy[key]
          end
        end

      end
    end
  end
end
