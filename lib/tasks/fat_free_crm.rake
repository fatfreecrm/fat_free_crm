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

namespace :ffcrm do
  namespace :config do
    desc "Setup database.yml"
    task :copy_database_yml do
      filename = "config/database.#{ENV['DB'] || 'postgres'}.yml"      
      orig, dest = FatFreeCRM.root.join(filename), Rails.root.join('config/database.yml')
      unless File.exists?(dest)
        puts "Copying #{filename} to config/database.yml ..."
        FileUtils.cp orig, dest
      end
    end
  end

  namespace :settings do
    desc "Clear settings from database (reset to default)"
    task :clear => :environment do
      puts "== Clearing settings table..."

      # Truncate settings table
      ActiveRecord::Base.establish_connection(Rails.env)
      if ActiveRecord::Base.connection.adapter_name.downcase == "sqlite"
        ActiveRecord::Base.connection.execute("DELETE FROM settings")
      else # mysql and postgres
        ActiveRecord::Base.connection.execute("TRUNCATE settings")
      end

      puts "===== Settings table has been cleared."
    end

    desc "Show current settings in the database"
    task :show => :environment do
      ActiveRecord::Base.establish_connection(Rails.env)
      names = ActiveRecord::Base.connection.select_values("SELECT name FROM settings ORDER BY name")
      names.each do |name|
        puts "\n#{name}:\n  #{Setting.send(name).inspect}"
      end
    end
  end

  desc "Prepare the database"
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
    Rake::Task["ffcrm:setup:admin"].invoke
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

  desc "Update country codes to ISO 3166-1"
  namespace :update_data do
    task :update_country_codes_to_iso3166_1 => :environment do
      convert_table = [
        ["Aland Islands", "FI", "AX"],
        ["Algeria", "AG", "DZ"],
        ["American Samoa", "AQ", "AS"],
        ["Andorra", "AN", "AD"],
        ["Anguilla", "AV", "AI"],
        ["Antarctica", "AY", "AQ"],
        ["Antigua and Barbuda", "AC", "AG"],
        ["Aruba", "AA", "AW"],
        ["Australia", "AS", "AU"],
        ["Austria", "AU", "AT"],
        ["Azerbaijan", "AJ", "AZ"],
        ["Bahamas", "BF", "BS"],
        ["Bahrain", "BA", "BH"],
        ["Bangladesh", "BG", "BD"],
        ["Belarus", "BO", "BY"],
        ["Belize", "BH", "BZ"],
        ["Benin", "BN", "BJ"],
        ["Bermuda", "BD", "BM"],
        ["Bosnia and Herzegovina", "BK", "BA"],
        ["Botswana", "BC", "BW"],
        ["Brunei Darussalam", "BX", "BN"],
        ["Bulgaria", "BU", "BG"],
        ["Burkina Faso", "UV", "BF"],
        ["Burundi", "BY", "BI"],
        ["Cambodia", "CB", "KH"],
        ["Cayman Islands", "CJ", "KY"],
        ["Central African Republic", "CT", "CF"],
        ["Chad", "CD", "TD"],
        ["Chile", "CI", "CL"],
        ["China", "CH", "CN"],
        ["Christmas Island", "KT", "CX"],
        ["Cocos (Keeling) Islands", "CK", "CC"],
        ["Comoros", "CN", "KM"],
        ["Congo, the Democratic Republic of the", "CF", "CD"],
        ["Cook Islands", "CW", "CK"],
        ["Costa Rica", "CS", "CR"],
        ["Czech Republic", "EZ", "CZ"],
        ["Denmark", "DA", "DK"],
        ["Dominica", "DO", "DM"],
        ["Dominican Republic", "DR", "DO"],
        ["El Salvador", "ES", "SV"],
        ["Equatorial Guinea", "EK", "GQ"],
        ["Estonia", "EN", "EE"],
        ["French Guiana", "FG", "GF"],
        ["French Polynesia", "FP", "PF"],
        ["French Southern Territories", "FS", "TF"],
        ["Gabon", "GB", "GA"],
        ["Gambia", "GA", "GM"],
        ["Georgia", "GG", "GE"],
        ["Germany", "GM", "DE"],
        ["Grenada", "GJ", "GD"],
        ["Guam", "GQ", "GU"],
        ["Guernsey", "GK", "GG"],
        ["Guinea", "GV", "GN"],
        ["Guinea-Bissau", "PU", "GW"],
        ["Haiti", "HA", "HT"],
        ["Holy See (Vatican City State)", "VT", "VA"],
        ["Honduras", "HO", "HN"],
        ["Iceland", "IC", "IS"],
        ["Iraq", "IZ", "IQ"],
        ["Ireland", "EI", "IE"],
        ["Israel", "IS", "IL"],
        ["Japan", "JA", "JP"],
        ["Kiribati", "KR", "KI"],
        ["Korea, Democratic People's Republic of", "KN", "KP"],
        ["Korea, Republic of", "KS", "KR"],
        ["Kuwait", "KU", "KW"],
        ["Latvia", "LG", "LV"],
        ["Lebanon", "LE", "LB"],
        ["Lesotho", "LT", "LS"],
        ["Liberia", "LI", "LR"],
        ["Liechtenstein", "LS", "LI"],
        ["Lithuania", "LH", "LT"],
        ["Macao", "MC", "MO"],
        ["Madagascar", "MA", "MG"],
        ["Malawi", "MI", "MW"],
        ["Marshall Islands", "RM", "MH"],
        ["Martinique", "MB", "MQ"],
        ["Mauritius", "MP", "MU"],
        ["Mayotte", "MF", "YT"],
        ["Monaco", "MN", "MC"],
        ["Mongolia", "MG", "MN"],
        ["Montenegro", "MJ", "ME"],
        ["Montserrat", "MH", "MS"],
        ["Morocco", "MO", "MA"],
        ["Myanmar", "BM", "MM"],
        ["Namibia", "WA", "NA"],
        ["Nicaragua", "NU", "NI"],
        ["Niger", "NG", "NE"],
        ["Nigeria", "NI", "NG"],
        ["Niue", "NE", "NU"],
        ["Northern Mariana Islands", "CQ", "MP"],
        ["Oman", "MU", "OM"],
        ["Palau", "PS", "PW"],
        ["Palestinian Territory, Occupied", "WE", "PS"],
        ["Panama", "PM", "PA"],
        ["Papua New Guinea", "PP", "PG"],
        ["Paraguay", "PA", "PY"],
        ["Philippines", "RP", "PH"],
        ["Pitcairn", "PC", "PN"],
        ["Portugal", "PO", "PT"],
        ["Puerto Rico", "RQ", "PR"],
        ["Russian Federation", "RS", "RU"],
        ["Saint Kitts and Nevis", "SC", "KN"],
        ["Saint Lucia", "ST", "LC"],
        ["Saint Pierre and Miquelon", "SB", "PM"],
        ["Sao Tome and Principe", "TP", "ST"],
        ["Senegal", "SG", "SN"],
        ["Serbia", "RB", "RS"],
        ["Seychelles", "SE", "SC"],
        ["Singapore", "SN", "SG"],
        ["Slovakia", "LO", "SK"],
        ["Solomon Islands", "BP", "SB"],
        ["South Africa", "SF", "ZA"],
        ["South Georgia and the South Sandwich Islands", "SX", "GS"],
        ["Spain", "SP", "ES"],
        ["Sri Lanka", "CE", "LK"],
        ["Sudan", "SU", "SD"],
        ["Suriname", "NS", "SR"],
        ["Svalbard and Jan Mayen", "SV", "SJ"],
        ["Swaziland", "WZ", "SZ"],
        ["Sweden", "SW", "SE"],
        ["Switzerland", "SZ", "CH"],
        ["Tajikistan", "TI", "TJ"],
        ["Timor-Leste", "TT", "TL"],
        ["Togo", "TO", "TG"],
        ["Tokelau", "TL", "TK"],
        ["Tonga", "TN", "TO"],
        ["Trinidad and Tobago", "TD", "TT"],
        ["Tunisia", "TS", "TN"],
        ["Turkey", "TU", "TR"],
        ["Turkmenistan", "TX", "TM"],
        ["Turks and Caicos Islands", "TK", "TC"],
        ["Ukraine", "UP", "UA"],
        ["United Kingdom", "UK", "GB"],
        ["Vanuatu", "NH", "VU"],
        ["Viet Nam", "VM", "VN"],
        ["Virgin Islands, British", "VI", "VG"],
        ["Virgin Islands, U.S.", "VQ", "VI"],
        ["Western Sahara", "WI", "EH"],
        ["Yemen", "YM", "YE"],
        ["Zambia", "ZA", "ZM"],
        ["Zimbabwe", "ZI", "ZW"],
        ["United States", "USA", "US"],
        ["United States", "United States", "US"],
        ["Argentina", "Argentina", "AR"],
        ["Australia", "Australia", "AU"],
        ["Brasil", "Brasil", "BR"],
        ["Canada", "Canada", "CA"],
        ["Finland", "Finland", "FI"],
        ["France", "France", "FR"],
        ["Germany", "Germany", "DE"],
        ["Italy", "Italy", "IT"],
        ["Japan", "Japan", "JP"],
        ["Mexico", "Mexico", "MX"],
        ["Norway", "Norway", "NO"],
        ["Poland", "Poland", "PL"],
        ["Portugal", "Portugal", "PT"],
        ["Spain", "Spain", "ES"],
        ["Sweden", "Sweden", "SE"],
        ["Russia", "Russia", "RU"],
        ["United Kingdom", "United Kingdom", "GB"]
      ]

      addresses_to_update = []

      convert_table.each { |ct|
        tmp = Address.where(:country => ct[1])
        tmp.map{ |t| t.country=ct[2] }
        
        unless tmp.blank?
          addresses_to_update << tmp
        end
      }

      begin
        addresses_to_update.each { |address_arr|
          address_arr.each { |address|
            address.save!
          }
        }  
      rescue Exception => e
        ActiveRecord::Rollback
        puts e
      end

    end
  end
end
