ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.
  map.root      :controller => "home", :action => "index"
  map.resource  :authentication
  map.resources :users, :member => { :avatar => :get, :upload_avatar => :put, :password => :get, :change_password => :put }
  map.resources :passwords
  map.resources :comments
  map.resources :tasks,         :has_many => :comments, :member => { :complete => :put }
  map.resources :accounts,      :has_many => :comments, :collection => { :search => :get, :auto_complete => :post, :options => :get, :redraw => :post }
  map.resources :campaigns,     :has_many => :comments, :collection => { :search => :get, :auto_complete => :post, :options => :get, :redraw => :post }
  map.resources :leads,         :has_many => :comments, :collection => { :search => :get, :auto_complete => :post, :options => :get, :redraw => :post }, :member => { :convert => :get, :promote => :put, :reject => :put }
  map.resources :contacts,      :has_many => :comments, :collection => { :search => :get, :auto_complete => :post, :options => :get, :redraw => :post }
  map.resources :opportunities, :has_many => :comments, :collection => { :search => :get, :auto_complete => :post, :options => :get, :redraw => :post }

  map.signup  "signup",  :controller => "users",           :action => "new"
  map.profile "profile", :controller => "users",           :action => "show"
  map.login   "login",   :controller => "authentications", :action => "new"
  map.logout  "logout",  :controller => "authentications", :action => "destroy"
  map.admin   "admin",   :controller => "admin/users",     :action => "index"

  map.namespace :admin do |admin|
    admin.resources :users, :collection => { :search => :get, :auto_complete => :post }, :member => { :suspend => :put, :reactivate => :put, :confirm => :get }
    admin.resources :settings
    admin.resources :plugins
  end

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  
  map.connect ":controller/:action/:id"
  map.connect ":controller/:action/:id.:format"
end
