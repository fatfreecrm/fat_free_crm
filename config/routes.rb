Rails.application.routes.draw do
  resources :lists

  root :to => 'home#index'

  match 'activities' => 'home#index'
  match 'admin'      => 'admin/users#index',       :as => :admin
  match 'login'      => 'authentications#new',     :as => :login
  match 'logout'     => 'authentications#destroy', :as => :logout
  match 'profile'    => 'users#show',              :as => :profile
  match 'signup'     => 'users#new',               :as => :signup

  match '/home/options',  :as => :options
  match '/home/toggle',   :as => :toggle
  match '/home/timeline', :as => :timeline
  match '/home/timezone', :as => :timezone
  match '/home/redraw',   :as => :redraw

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
      get :versions
    end
    member do
      put  :attach
      post :discard
      post :subscribe
      post :unsubscribe
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
      get :versions
    end
    member do
      put  :attach
      post :discard
      post :subscribe
      post :unsubscribe
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
      get :versions
    end
    member do
      put  :attach
      post :discard
      post :subscribe
      post :unsubscribe
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
      get :versions
    end
    member do
      get  :convert
      post :discard
      post :subscribe
      post :unsubscribe
      put  :attach
      put  :promote
      put  :reject
    end

    get :autocomplete_account_name, :on => :collection
  end

  resources :opportunities, :id => /\d+/ do
    collection do
      get  :advanced_search
      post :filter
      get  :options
      get  :field_group
      post :auto_complete
      post :redraw
      get :versions
    end
    member do
      put  :attach
      post :discard
      post :subscribe
      post :unsubscribe
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
      post :redraw
    end

    collection do
      match :auto_complete
    end
  end

  namespace :admin do
    resources :groups

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
        get :subform
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
