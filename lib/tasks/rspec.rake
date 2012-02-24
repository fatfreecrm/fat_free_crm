if defined?(RSpec)
  namespace :spec do
    desc "Preparing test env"
    task :prepare do
      tmp_env = Rails.env
      Rails.env = "test"
      Rake::Task["crm:copy_default_config"].invoke
      puts "Preparing test database..."
      Rake::Task["db:schema:load"].invoke
      Rake::Task["crm:settings:load"].invoke
      Rails.env = tmp_env
    end
    
    desc "Run all specs except acceptance"
    RSpec::Core::RakeTask.new(:no_acceptance => "spec:prepare") do |c|
      include_dirs = Dir["./spec/*/"].map { |dir| File.basename(dir) } - ["acceptance"]
      c.pattern = "./spec/{#{include_dirs.join(",")}}/**/*_spec.rb"
    end  
  end

  Rake::Task["spec"].prerequisites.clear
  Rake::Task["spec"].prerequisites.push("spec:prepare")
end