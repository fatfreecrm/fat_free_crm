namespace :db do
  namespace :settings do
    desc "Load default application settings"
    task :load => :environment do
      puts "Loading default settings for #{Rails.env}..."
      ActiveRecord::Base.establish_connection(Rails.env)
      ActiveRecord::Base.connection.execute("TRUNCATE settings")
      settings = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")
      settings.keys.each do |key|
        sql = [ "INSERT INTO settings SET name=?, default_value=?", key.to_s, Base64.encode64(Marshal.dump(settings[key])) ]
        ActiveRecord::Base.connection.execute(ActiveRecord::Base.send(:sanitize_sql, sql))
      end
    end
  end
end
