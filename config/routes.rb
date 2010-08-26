FatFreeCrm::Application.routes.draw do

  root :to => 'home#index'
  match '/' => 'home#index'

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

  resources :tasks do
    collection do
      post :auto_complete
    end
    member do
      put :complete
    end
  end

  resources :leads do
    collection do
      post :auto_complete
      get :options
      post :redraw
      get :search
    end
    member do
      put :attach
      get :convert
      post :discard
      put :promote
      put :reject
    end
  end

  resources :accounts do
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

  resources :campaigns do
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

  resources :contacts do
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

  resources :opportunities do
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

  match 'signup' => 'users#new', :as => :signup
  match 'profile' => 'users#show', :as => :profile
  match 'login' => 'authentications#new', :as => :login
  match 'logout' => 'authentications#destroy', :as => :logout
  match 'admin' => 'admin/users#index', :as => :admin

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
