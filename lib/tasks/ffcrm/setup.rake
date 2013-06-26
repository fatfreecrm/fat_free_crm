# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
namespace :ffcrm do

  desc "Prepare the database"
  task :setup => :environment do
    if ENV["PROCEED"] != 'true'
      puts "\nFatFree CRM is about to run migrations on your database. Make sure you have a backup before proceeding.\n\n"
      proceed = false
      loop do
        print "Continue [yes/no]: "
        proceed = STDIN.gets.strip
        break unless proceed.blank?
      end

      # Don't continue unless user typed y(es)
      if proceed =~ /y(?:es)*/i
        Rake::Task["db:migrate"].invoke
        Rake::Task["ffcrm:setup:admin"].invoke
      else
        puts "Aborted setup."
      end
    end

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
      user.update_attribute(:suspended_at, nil) # Mass assignments don't work for :suspended_at because of the attr_protected
      puts "Admin user has been created."
    end
  end

end
