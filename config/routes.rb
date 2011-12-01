FatFreeCRM::Application.routes.draw do
  scope (!Setting.table_exists? || Setting.base_url.blank?) ? "/" : Setting.base_url do
    root :to => 'home#index'

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

    resources :accounts do
      collection do
        post :filter
        get  :options
        get  :search
        get  :field_group
        post :auto_complete
        post :redraw
      end
      member do
        put  :attach
        post :discard
      end
    end

    resources :campaigns do
      collection do
        post :filter
        get  :options
        get  :search
        get  :field_group
        post :auto_complete
        post :redraw
      end
      member do
        put  :attach
        post :discard
      end
    end

    resources :contacts do
      collection do
        post :filter
        get  :options
        get  :search
        get  :field_group
        post :auto_complete
        post :redraw
      end
      member do
        put  :attach
        post :discard
      end
    end

    resources :leads do
      collection do
        post :filter
        get  :options
        get  :search
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

    resources :opportunities do
      collection do
        post :filter
        get  :options
        get  :search
        get  :field_group
        post :auto_complete
        post :redraw
      end
      member do
        put  :attach
        post :discard
      end
    end

    resources :tasks do
      collection do
        post :filter
        post :auto_complete
      end
      member do
        put :complete
      end
    end

    resources :users do
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
          get  :search
          post :auto_complete
        end
        member do
          get :confirm
          put :suspend
          put :reactivate
        end
      end

      resources :fields do
        collection do
          post :auto_complete
          get :options
          post :redraw
          get :search
          post :sort
          post :group_sort
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

