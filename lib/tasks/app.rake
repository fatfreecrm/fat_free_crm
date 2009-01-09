namespace :app do

  namespace :settings do
    desc "Load default application settings"
    task :load => :environment do
      ActiveRecord::Base.establish_connection(Rails.env)
      if ActiveRecord::Base.connection.adapter_name.downcase == "mysql"
        ActiveRecord::Base.connection.execute("TRUNCATE settings")
      else
        ActiveRecord::Base.connection.execute("DELETE FROM settings")
      end
      settings = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")
      settings.keys.each do |key|
        sql = [ "INSERT INTO settings (name, default_value) VALUES(?, ?)", key.to_s, Base64.encode64(Marshal.dump(settings[key])) ]
        ActiveRecord::Base.connection.execute(ActiveRecord::Base.send(:sanitize_sql, sql))
      end
    end
  end

  desc "Prepare the database and load default application settings"
  task :setup => :environment do
    Rake::Task["db:migrate:reset"].invoke
    Rake::Task["app:settings:load"].invoke
  end

  desc "Load randomly generated demo data and restore default application settings"
  task :demo => :environment do
    Rake::Task["spec:db:fixtures:load"].invoke      # loading fixtures truncates settings!
    Rake::Task["app:settings:load"].invoke
  end

  desc "Reset the database and reload default application settings and demo data"
  task :reset => :environment do
    Rake::Task["db:migrate:reset"].invoke
    Rake::Task["app:demo"].invoke
  end
end
