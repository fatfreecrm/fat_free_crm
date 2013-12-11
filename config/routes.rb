# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
Rails.application.routes.draw do
  resources :lists

  root :to => 'home#index'

  get 'activities' => 'home#index'
  get 'admin'      => 'admin/users#index',       :as => :admin
  get 'login'      => 'authentications#new',     :as => :login
  delete 'logout'     => 'authentications#destroy', :as => :logout
  get 'profile'    => 'users#show',              :as => :profile
  get 'signup'     => 'users#new',               :as => :signup

  get '/home/options',  :as => :options
  get '/home/toggle',   :as => :toggle
  patch '/home/timeline', :as => :timeline
  post '/home/timezone', :as => :timezone
  post '/home/redraw',   :as => :redraw

  resource  :authentication
  resources :comments, :except => [:new, :show]
  resources :emails
  resources :passwords

  resources :accounts, :id => /\d+/ do
    collection do
      get  :advanced_search
      post :filter
      get  :options
      get  :field_group
      get :auto_complete
      post :redraw
      get :versions
    end
    member do
      patch  :attach
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
      patch  :attach
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
      patch  :attach
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
      patch  :attach
      patch  :promote
      patch  :reject
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
      patch  :attach
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
      patch :complete
    end
  end

  resources :users, :id => /\d+/ do
    member do
      get :avatar
      get :password
      patch :upload_avatar
      patch :change_password
      post :redraw
    end

    collection do
      get :auto_complete
      get :opportunities_overview
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
        patch :suspend
        patch :reactivate
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
