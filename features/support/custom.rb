Spork.prefork do
  require "factory_girl"
  require RAILS_ROOT + "/spec/factories"
end

Spork.each_run do
end

