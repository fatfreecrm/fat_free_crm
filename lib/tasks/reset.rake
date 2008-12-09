namespace :app do
  desc "Reset the database, sample fixtures, and default application settings"
  task :reset => :environment do
    Rake::Task['db:migrate:reset'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['spec:db:fixtures:load'].invoke
    Rake::Task['db:settings:load'].invoke
  end
end
