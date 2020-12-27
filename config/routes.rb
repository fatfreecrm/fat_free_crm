# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
Rails.application.routes.draw do
  resources :lists

  root to: 'home#index'

  # Deprecated: Compatibility with legacy Authlogic routes
  get '/login',  to: redirect('/users/sign_in')
  get '/signup', to: redirect('/users/sign_up')

  devise_for :users, controllers: { registrations: 'registrations',
                                    sessions: 'sessions',
                                    passwords: 'passwords',
                                    confirmations: 'confirmations' }

  devise_scope :user do
    resources :users, only: %i[index show] do
      collection do
        get :opportunities_overview
      end
    end
  end

  get 'activities' => 'home#index'
  get 'admin'      => 'admin/users#index',       as: :admin
  get 'profile'    => 'users#show',              as: :profile

  get '/home/options',  as: :options
  get '/home/toggle',   as: :toggle
  match '/home/timeline', as: :timeline, via: %i[get put post]
  match '/home/timezone', as: :timezone, via: %i[get put post]
  post '/home/redraw', as: :redraw

  resources :comments,       except: %i[new show]
  resources :emails,         only: [:destroy]

  resources :accounts, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: %i[get post]
      get :redraw
      get :versions
    end
    member do
      put :attach
      post :discard
      post :subscribe
      post :unsubscribe
      get :contacts
      get :opportunities
    end
  end

  resources :campaigns, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: %i[get post]
      get :redraw
      get :versions
    end
    member do
      put :attach
      post :discard
      post :subscribe
      post :unsubscribe
      get :leads
      get :opportunities
    end
  end

  resources :contacts, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: %i[get post]
      get :redraw
      get :versions
    end
    member do
      put :attach
      post :discard
      post :subscribe
      post :unsubscribe
      get :opportunities
    end
  end

  resources :leads, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: %i[get post]
      get :redraw
      get :versions
      get :autocomplete_account_name
    end
    member do
      get :convert
      post :discard
      post :subscribe
      post :unsubscribe
      put :attach
      match :promote, via: %i[patch put]
      put :reject
    end
  end

  resources :opportunities, id: /\d+/ do
    collection do
      get :advanced_search
      post :filter
      get :options
      get :field_group
      match :auto_complete, via: %i[get post]
      get :redraw
      get :versions
    end
    member do
      put :attach
      post :discard
      post :subscribe
      post :unsubscribe
      get :contacts
    end
  end

  resources :tasks, id: /\d+/ do
    collection do
      post :filter
      match :auto_complete, via: %i[get post]
    end
    member do
      put :complete
      put :uncomplete
    end
  end

  resources :users, id: /\d+/, except: %i[index destroy create] do
    member do
      get :avatar
      get :password
      match :upload_avatar, via: %i[put patch]
      patch :change_password
      post :redraw
    end
    collection do
      match :auto_complete, via: %i[get post]
    end
  end

  namespace :admin do
    resources :groups

    resources :users do
      collection do
        match :auto_complete, via: %i[get post]
      end
      member do
        get :confirm
        put :suspend
        put :reactivate
      end
    end

    resources :field_groups, except: %i[index show] do
      collection do
        post :sort
      end
      member do
        get :confirm
      end
    end

    resources :fields do
      collection do
        match :auto_complete, via: %i[get post]
        get :options
        get :redraw
        post :sort
        get :subform
      end
    end

    resources :tags, except: [:show] do
      member do
        get :confirm
      end
    end

    resources :fields, as: :custom_fields
    resources :fields, as: :core_fields

    resources :settings, only: :index
    resources :plugins,  only: :index
  end

  get 'importers/new/:entity_type(/:entity_id)' => 'importers#new', as: :new_importer
  post 'importers' => 'importers#create', as: :create_importer
  get 'importers/:id/map' => 'importers#form_map_columns', as: :form_map_columns_importer
  post 'importers/:id/map' => 'importers#map_columns', as: :map_columns_importer
end
