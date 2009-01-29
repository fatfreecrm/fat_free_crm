namespace :crm do

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
    Rake::Task["crm:settings:load"].invoke
  end

  namespace :demo do
    desc "Load demo data and default application settings"
    task :load => :environment do
      Rake::Task["spec:db:fixtures:load"].invoke      # loading fixtures truncates settings!
      Rake::Task["crm:settings:load"].invoke
    end

    desc "Reset the database and reload demo data along with default application settings"
    task :reload => :environment do
      Rake::Task["db:migrate:reset"].invoke
      Rake::Task["crm:demo:load"].invoke
    end
  end
end
