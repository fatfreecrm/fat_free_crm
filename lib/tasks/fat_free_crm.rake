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

      # Simulate random user activities.
      $stdout.sync = true
      puts "Generating user activities..."
      %w(Account Campaign Contact Lead Opportunity Task).inject([]) do |assets, model|
        assets << model.constantize.send(:find, :all)
      end.flatten.shuffle.each do |subject|
        info = subject.respond_to?(:full_name) ? subject.full_name : subject.name
        Activity.create(:action => "created", :created_at => subject.updated_at, :user => subject.user, :subject => subject, :info => info)
        Activity.create(:action => "updated", :created_at => subject.updated_at, :user => subject.user, :subject => subject, :info => info)
        unless subject.is_a?(Task)
          time = subject.updated_at + rand(12 * 60).minutes
          Activity.create(:action => "viewed", :created_at => time, :user => subject.user, :subject => subject, :info => info)
          comments = Comment.find(:all, :conditions => [ "commentable_id=? AND commentable_type=?", subject.id, subject.class.name ])
          comments.each_with_index do |comment, i|
            time = subject.created_at + rand(12 * 60 * i).minutes
            if time > Time.now
              time = subject.created_at + rand(600).minutes
            end
            comment.update_attribute(:created_at, time)
            Activity.create(:action => "commented", :created_at => time, :user => comment.user, :subject => subject, :info => info)
          end
        end
        print "." if subject.id % 10 == 0
      end
      puts
    end

    desc "Reset the database and reload demo data along with default application settings"
    task :reload => :environment do
      Rake::Task["db:migrate:reset"].invoke
      Rake::Task["crm:demo:load"].invoke
    end
  end
end
