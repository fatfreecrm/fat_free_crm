ActionController::Routing::Routes.draw do |map|
  map.apples  "apples",  :controller => "apples"
  map.oranges "oranges", :controller => "oranges"

  map.namespace :admin do |admin|
    map.bananas "bananas", :controller => "bananas"
  end

end
