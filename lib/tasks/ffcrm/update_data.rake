# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
namespace :ffcrm do
  namespace :update_data do

    #
    # Important note about countries. Please read carefully!
    #
    # The country mapping in lib/plugins/country_select/lib/country_select.rb
    # was found to be wrong. E.g. Australia was originally mapped to AS, which is
    # officially the ISO code for American Samoa. (This is just one example!)
    # From this point on, it will be mapped to AU, the correct ISO code for Australia.
    # It is critical that you run 'rake ffcrm:update_data:fix_countries' to fix your address data.
    #
    # However, please note, this task should only ever be run ONCE!
    #
    # If you run it multiple times on the same database then you will mess up your existing
    # address data. E.g. running once will map AS -> AU (Australia) and AU -> AT (Austria). If you run
    # that again, it will map all Australian countries to Austria!! (...and so on for all the
    # other mappings that have changed.)
    #
    # This message is also included in a migration and checks whether it has run before.
    # i.e. if Setting.have_run_country_migration has been set.
    # If not, it asks you to run this rake task.
    #
    desc "Update country codes to ISO 3166-1"
    task :fix_countries => :environment do
    
      message = """This task is only designed to run once and we think you've run this before!!!

Please read the following carefully!

The country mapping in lib/plugins/country_select/lib/country_select.rb
was found to be wrong. E.g. Australia was originally mapped to AS, which is
officially the ISO code for American Samoa. (This is just one example!)
From this point on, it will be mapped to AU, the correct ISO code for Australia.
It is critical that you run 'rake ffcrm:update_data:fix_countries' to fix your address data.

However, please note, this task should only ever be run ONCE!

If you run it multiple times on the same database then you will mess up your existing
address data. E.g. running once will map AS -> AU (Australia) and AU -> AT (Austria). If you run
that again, it will map all Australian countries to Austria!! (...and so on for all the
other mappings that have changed.)

This message is also included in a migration and checks whether it has run before.
i.e. if Setting.have_run_country_migration has been set. If not, it asks you to run this rake task.

If you really want to run it again, you will have to set Setting.have_run_country_migration = false
in a console and continue. This is strongly discouraged. You have been warned!

"""
      
      if Setting.have_run_country_migration == true
        puts message
        exit
      end
    
      convert_table = [
        #["Aland Islands", "FI", "AX"], # this clashed with FI for Finland. We'll prefer Finland.
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
      ]

      addresses_to_update = []

      # e.g. convert AS -> AU and Australia -> AU
      # SELECT "addresses".* FROM "addresses" 
      #    WHERE (("addresses"."country" = 'AU' OR "addresses"."country" = 'Australia'))
      convert_table.each { |ct|
        t=Address.arel_table
        scope = t[:country].eq(ct[0]) # Australia
        scope = scope.or(t[:country].eq(ct[1])) # AU

        tmp = Address.where(scope)
        tmp.map{ |t| t.country=ct[2] }
        
        unless tmp.blank?
          addresses_to_update << tmp
        end
      }

      Address.transaction do
        begin
          addresses_to_update.each { |address_arr|
            address_arr.each { |address|
              address.save!
            }
          }
          Setting.have_run_country_migration = true
        rescue Exception => e
          ActiveRecord::Rollback
          puts e
        end
      end

    end
  end

end
