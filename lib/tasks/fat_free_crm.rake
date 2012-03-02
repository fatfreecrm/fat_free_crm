# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

require 'fileutils'

class Rake::Task
  def self.sanitize_and_execute(sql)
    sanitized = ActiveRecord::Base.send(:sanitize_sql, sql, nil)
    ActiveRecord::Base.connection.execute(sanitized)
  end
end

namespace :crm do
  desc "Copy example config files"
  task :copy_default_config do
    puts "Copying example config files..."    
    FileUtils.cp "config/settings.yml.example", "config/settings.yml" unless File.exists?("config/settings.yml")
    FileUtils.cp "config/database.#{ENV['DB'] || 'postgres'}.yml", 'config/database.yml' unless File.exists?("config/database.yml")
  end

  namespace :settings do
    desc "Load default application settings"
    task :load => :environment do
      plugin = ENV["PLUGIN"]
      yaml = File.join(Rails.root, (plugin ? "/vendor/plugins/#{plugin}" : "") + "/config/settings.yml")

      puts "== Loading settings#{plugin ? (' from ' << plugin) : ''}..."

      begin
        settings = YAML.load_file(yaml)
      rescue
        puts "Couldn't load #{yaml} configuration file."
        exit
      end

      # Truncate settings table if loading Fat Free CRM settings.
      ActiveRecord::Base.establish_connection(Rails.env)
      unless plugin
        if ActiveRecord::Base.connection.adapter_name.downcase == "sqlite"
          ActiveRecord::Base.connection.execute("DELETE FROM settings")
        else # mysql and postgres
          ActiveRecord::Base.connection.execute("TRUNCATE settings")
        end
      end

      settings.keys.each do |key|
        if plugin # Delete existing plugin setting if any (since we haven't truncated the whole table).
          sql = [ "DELETE FROM settings WHERE name = ?", key.to_s ]
          Rake::Task.sanitize_and_execute(sql)
        end
        sql = [ "INSERT INTO settings (name, default_value, created_at, updated_at) VALUES(?, ?, ?, ?)", key.to_s, Base64.encode64(Marshal.dump(settings[key])), Time.now, Time.now ]
        Rake::Task.sanitize_and_execute(sql)
      end

      # Change default access on models, as specified in settings.yml
      %w(leads opportunities contacts campaigns accounts).each do |table|
        ActiveRecord::Migration.change_column_default(table, 'access', settings[:default_access])
      end
      # Re-dump the schema in case default access has changed (Critical for RSpec)
      Rake::Task["db:schema:dump"].invoke

      puts "===== Settings have been loaded."
    end

    desc "Show current application settings"
    task :show => :environment do
      ActiveRecord::Base.establish_connection(Rails.env)
      names = ActiveRecord::Base.connection.select_values("SELECT name FROM settings ORDER BY name")
      names.each do |name|
        puts "\n#{name}:\n  #{Setting.send(name).inspect}"
      end
    end
  end

  desc "Prepare the database and load default application settings"
  task :setup => :environment do
    if ENV["PROCEED"] != 'true' and ActiveRecord::Migrator.current_version > 0
      puts "\nYour database is about to be reset, so if you choose to proceed all the existing data will be lost.\n\n"
      proceed = false
      loop do
        print "Continue [yes/no]: "
        proceed = STDIN.gets.strip
        break unless proceed.blank?
      end
      return unless proceed =~ /y(?:es)*/i # Don't continue unless user typed y(es)
    end
    Rake::Task["db:migrate:reset"].invoke
    # Migrating plugins is not part of Rails 3 yet, but it is coming. See
    # https://rails.lighthouseapp.com/projects/8994/tickets/2058 for details.
    Rake::Task["db:migrate:plugins"].invoke rescue nil
    Rake::Task["crm:settings:load"].invoke
    Rake::Task["crm:setup:admin"].invoke
  end

  namespace :setup do
    desc "Create admin user"
    task :admin => :environment do
      username, password, email = ENV["USERNAME"], ENV["PASSWORD"], ENV["EMAIL"]
      unless username && password && email
        puts "\nTo create the admin user you will be prompted to enter username, password,"
        puts "and email address. You might also specify the username of existing user.\n"
        loop do
          username ||= "system"
          print "\nUsername [#{username}]: "
          reply = STDIN.gets.strip
          username = reply unless reply.blank?

          password ||= "manager"
          print "Password [#{password}]: "
          echo = lambda { |toggle| return if RUBY_PLATFORM =~ /mswin/; system(toggle ? "stty echo && echo" : "stty -echo") }
          begin
            echo.call(false)
            reply = STDIN.gets.strip
            password = reply unless reply.blank?
          ensure
            echo.call(true)
          end

          loop do
            print "Email: "
            email = STDIN.gets.strip
            break unless email.blank?
          end

          puts "\nThe admin user will be created with the following credentials:\n\n"
          puts "  Username: #{username}"
          puts "  Password: #{'*' * password.length}"
          puts "     Email: #{email}\n\n"
          loop do
            print "Continue [yes/no/exit]: "
            reply = STDIN.gets.strip
            break unless reply.blank?
          end
          break if reply =~ /y(?:es)*/i
          redo if reply =~ /no*/i
          puts "No admin user was created."
          exit
        end
      end
      User.reset_column_information # Reload the class since we've added new fields in migrations.
      user = User.find_by_username(username) || User.new
      user.update_attributes(:username => username, :password => password, :email => email)
      user.update_attribute(:admin, true) # Mass assignments don't work for :admin because of the attr_protected
      puts "Admin user has been created."
    end
  end

  namespace :demo do
    desc "Load demo data and default application settings"
    task :load => :environment do
      Rake::Task["spec:db:fixtures:load"].invoke      # loading fixtures truncates settings!
      Rake::Task["crm:settings:load"].invoke

      # Simulate random user activities.
      $stdout.sync = true
      puts "Generating user activities..."
      %w(Account Campaign Contact Lead Opportunity Task).map do |model|
        model.constantize.send(:find, :all)
      end.flatten.shuffle.each do |subject|
        info = subject.respond_to?(:full_name) ? subject.full_name : subject.name
        Activity.create(:action => "created", :created_at => subject.updated_at, :user => subject.user, :subject => subject, :info => info)
        Activity.create(:action => "updated", :created_at => subject.updated_at, :user => subject.user, :subject => subject, :info => info)
        unless subject.is_a?(Task)
          time = subject.updated_at + rand(12 * 60).minutes
          Activity.create(:action => "viewed", :created_at => time, :user => subject.user, :subject => subject, :info => info)
          comments = Comment.where(:commentable_id => subject.id, :commentable_type => subject.class.name)
          comments.each_with_index do |comment, i|
            time = subject.created_at + rand(12 * 60 * i).minutes
            if time > Time.now
              time = subject.created_at + rand(600).minutes
            end
            comment.update_attribute(:created_at, time)
            Activity.create(:action => "commented", :created_at => time, :user => comment.user, :subject => subject, :info => info)
          end
          emails = Email.where(:mediator_id => subject.id, :mediator_type => subject.class.name)
          emails.each do |email|
            time = subject.created_at + rand(24 * 60).minutes
            if time > Time.now
              time = subject.created_at + rand(600).minutes
            end
            sent_at = time - rand(600).minutes
            received_at = sent_at + rand(600).seconds
            email.update_attributes(:created_at => time, :sent_at => sent_at, :received_at => received_at)
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

