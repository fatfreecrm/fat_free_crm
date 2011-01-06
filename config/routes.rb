FatFreeCRM::Application.routes.draw do

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
  match 'toggle'     => 'home#toggle'
  match 'redraw'     => 'home#redraw'

  resource :authentication

  resources :users do
    member do
      get :avatar
      put :upload_avatar
      get :password
      put :change_password
    end
  end

  resources :passwords

  resources :comments

  resources :emails

  resources :tasks, :constraints => {:id => /\d+/} do
    collection do
      post :auto_complete
      post :filter
    end
    member do
      put :complete
    end
  end

  resources :leads, :constraints => {:id => /\d+/} do
    collection do
      post :auto_complete
      get :options
      post :redraw
      get :search
      post :filter
    end
    member do
      put :attach
      get :convert
      post :discard
      put :promote
      put :reject
    end
  end

  resources :accounts, :constraints => {:id => /\d+/} do
    collection do
      post :auto_complete
      get :options
      post :redraw
      get :search
    end
    member do
      put :attach
      post :discard
    end
  end

  resources :campaigns, :constraints => {:id => /\d+/} do
    collection do
      post :auto_complete
      get :options
      post :redraw
      get :search
      post :filter
    end
    member do
      put :attach
      post :discard
    end
  end

  resources :contacts, :constraints => {:id => /\d+/} do
    collection do
      post :auto_complete
      get :options
      post :redraw
      get :search
    end
    member do
      put :attach
      post :discard
    end
  end

  resources :opportunities, :constraints => {:id => /\d+/} do
    collection do
      post :auto_complete
      get :options
      post :redraw
      get :search
      post :filter
    end
    member do
      put :attach
      post :discard
    end
  end

  namespace :admin do
    resources :users do
      collection do
        get :search
        post :auto_complete
      end
      member do
        put :suspend
        put :reactivate
        get :confirm
      end
    end
    resources :settings
    resources :plugins
  end
end
