FatFreeCRM::Application.routes.draw do
  resources :lists

  scope Setting.base_url.to_s do
    root :to => 'home#index'

    bushido_authentication_routes if Bushido::Platform.on_bushido?
    
    match 'activities' => 'home#index'
    match 'admin'      => 'admin/users#index',       :as => :admin
    match 'login'      => 'authentications#new',     :as => :login
    match 'logout'     => 'authentications#destroy', :as => :logout
    match 'options'    => 'home#options'
    match 'profile'    => 'users#show',              :as => :profile
    match 'signup'     => 'users#new',               :as => :signup
    match 'timeline'   => 'home#timeline',           :as => :timeline
    match 'timezone'   => 'home#timezone',           :as => :timezone
    match 'redraw'     => 'home#redraw',             :as => :redraw
    match 'toggle'     => 'home#toggle'

    resource  :authentication
    resources :comments
    resources :emails
    resources :passwords

    resources :accounts, :id => /\d+/ do
      collection do
        get  :advanced_search
        post :filter
        get  :options
        get  :field_group
        match :auto_complete
        post :redraw
      end
      member do
        put  :attach
        post :discard
        get :contacts
        get :opportunities
      end
    end

    resources :campaigns, :id => /\d+/ do
      collection do
        get  :advanced_search
        post :filter
        get  :options
        get  :field_group
        post :auto_complete
        post :redraw
      end
      member do
        put  :attach
        post :discard
        get :leads
        get :opportunities
      end
    end

    resources :contacts, :id => /\d+/ do
      collection do
        get  :advanced_search
        post :filter
        get  :options
        get  :field_group
        post :auto_complete
        post :redraw
      end
      member do
        put  :attach
        post :discard
        get :opportunities
      end
    end

    resources :leads, :id => /\d+/ do
      collection do
        get  :advanced_search
        post :filter
        get  :options
        get  :field_group
        post :auto_complete
        post :redraw
      end
      member do
        get  :convert
        post :discard
        put  :attach
        put  :promote
        put  :reject
      end
    end

    resources :opportunities, :id => /\d+/ do
      collection do
        get  :advanced_search
        post :filter
        get  :options
        get  :field_group
        post :auto_complete
        post :redraw
      end
      member do
        put  :attach
        post :discard
        get :contacts
      end
    end

    resources :tasks, :id => /\d+/ do
      collection do
        post :filter
        post :auto_complete
      end
      member do
        put :complete
      end
    end

    resources :users, :id => /\d+/ do
      member do
        get :avatar
        get :password
        put :upload_avatar
        put :change_password
      end
    end

    namespace :admin do
      resources :users do
        collection do
          post :auto_complete
        end
        member do
          get :confirm
          put :suspend
          put :reactivate
        end
      end

      resources :field_groups, :except => :index do
        collection do
          post :sort
        end
        member do
          get :confirm
        end
      end

      resources :fields do
        collection do
          post :auto_complete
          get :options
          post :redraw
          post :sort
        end
      end
      
      resources :tags do
        member do
          get :confirm
        end
      end
      
      resources :fields, :as => :custom_fields
      resources :fields, :as => :core_fields

      resources :settings
      resources :plugins
    end

    get '/:controller/tagged/:id' => '#tagged'
  end
end

