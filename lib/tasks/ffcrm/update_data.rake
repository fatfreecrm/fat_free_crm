# frozen_string_literal: true

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
    task fix_countries: :environment do
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
        # ["Aland Islands", "FI", "AX"], # this clashed with FI for Finland. We'll prefer Finland.
        %w[Algeria AG DZ],
        ["American Samoa", "AQ", "AS"],
        %w[Andorra AN AD],
        %w[Anguilla AV AI],
        %w[Antarctica AY AQ],
        ["Antigua and Barbuda", "AC", "AG"],
        %w[Aruba AA AW],
        %w[Australia AS AU],
        %w[Austria AU AT],
        %w[Azerbaijan AJ AZ],
        %w[Bahamas BF BS],
        %w[Bahrain BA BH],
        %w[Bangladesh BG BD],
        %w[Belarus BO BY],
        %w[Belize BH BZ],
        %w[Benin BN BJ],
        %w[Bermuda BD BM],
        ["Bosnia and Herzegovina", "BK", "BA"],
        %w[Botswana BC BW],
        ["Brunei Darussalam", "BX", "BN"],
        %w[Bulgaria BU BG],
        ["Burkina Faso", "UV", "BF"],
        %w[Burundi BY BI],
        %w[Cambodia CB KH],
        ["Cayman Islands", "CJ", "KY"],
        ["Central African Republic", "CT", "CF"],
        %w[Chad CD TD],
        %w[Chile CI CL],
        %w[China CH CN],
        ["Christmas Island", "KT", "CX"],
        ["Cocos (Keeling) Islands", "CK", "CC"],
        %w[Comoros CN KM],
        ["Congo, the Democratic Republic of the", "CF", "CD"],
        ["Cook Islands", "CW", "CK"],
        ["Costa Rica", "CS", "CR"],
        ["Czech Republic", "EZ", "CZ"],
        %w[Denmark DA DK],
        %w[Dominica DO DM],
        ["Dominican Republic", "DR", "DO"],
        ["El Salvador", "ES", "SV"],
        ["Equatorial Guinea", "EK", "GQ"],
        %w[Estonia EN EE],
        ["French Guiana", "FG", "GF"],
        ["French Polynesia", "FP", "PF"],
        ["French Southern Territories", "FS", "TF"],
        %w[Gabon GB GA],
        %w[Gambia GA GM],
        %w[Georgia GG GE],
        %w[Germany GM DE],
        %w[Grenada GJ GD],
        %w[Guam GQ GU],
        %w[Guernsey GK GG],
        %w[Guinea GV GN],
        %w[Guinea-Bissau PU GW],
        %w[Haiti HA HT],
        ["Holy See (Vatican City State)", "VT", "VA"],
        %w[Honduras HO HN],
        %w[Iceland IC IS],
        %w[Iraq IZ IQ],
        %w[Ireland EI IE],
        %w[Israel IS IL],
        %w[Japan JA JP],
        %w[Kiribati KR KI],
        ["Korea, Democratic People's Republic of", "KN", "KP"],
        ["Korea, Republic of", "KS", "KR"],
        %w[Kuwait KU KW],
        %w[Latvia LG LV],
        %w[Lebanon LE LB],
        %w[Lesotho LT LS],
        %w[Liberia LI LR],
        %w[Liechtenstein LS LI],
        %w[Lithuania LH LT],
        %w[Macao MC MO],
        %w[Madagascar MA MG],
        %w[Malawi MI MW],
        ["Marshall Islands", "RM", "MH"],
        %w[Martinique MB MQ],
        %w[Mauritius MP MU],
        %w[Mayotte MF YT],
        %w[Monaco MN MC],
        %w[Mongolia MG MN],
        %w[Montenegro MJ ME],
        %w[Montserrat MH MS],
        %w[Morocco MO MA],
        %w[Myanmar BM MM],
        %w[Namibia WA NA],
        %w[Nicaragua NU NI],
        %w[Niger NG NE],
        %w[Nigeria NI NG],
        %w[Niue NE NU],
        ["Northern Mariana Islands", "CQ", "MP"],
        %w[Oman MU OM],
        %w[Palau PS PW],
        ["Palestinian Territory, Occupied", "WE", "PS"],
        %w[Panama PM PA],
        ["Papua New Guinea", "PP", "PG"],
        %w[Paraguay PA PY],
        %w[Philippines RP PH],
        %w[Pitcairn PC PN],
        %w[Portugal PO PT],
        ["Puerto Rico", "RQ", "PR"],
        ["Russian Federation", "RS", "RU"],
        ["Saint Kitts and Nevis", "SC", "KN"],
        ["Saint Lucia", "ST", "LC"],
        ["Saint Pierre and Miquelon", "SB", "PM"],
        ["Sao Tome and Principe", "TP", "ST"],
        %w[Senegal SG SN],
        %w[Serbia RB RS],
        %w[Seychelles SE SC],
        %w[Singapore SN SG],
        %w[Slovakia LO SK],
        ["Solomon Islands", "BP", "SB"],
        ["South Africa", "SF", "ZA"],
        ["South Georgia and the South Sandwich Islands", "SX", "GS"],
        %w[Spain SP ES],
        ["Sri Lanka", "CE", "LK"],
        %w[Sudan SU SD],
        %w[Suriname NS SR],
        ["Svalbard and Jan Mayen", "SV", "SJ"],
        %w[Swaziland WZ SZ],
        %w[Sweden SW SE],
        %w[Switzerland SZ CH],
        %w[Tajikistan TI TJ],
        %w[Timor-Leste TT TL],
        %w[Togo TO TG],
        %w[Tokelau TL TK],
        %w[Tonga TN TO],
        ["Trinidad and Tobago", "TD", "TT"],
        %w[Tunisia TS TN],
        %w[Turkey TU TR],
        %w[Turkmenistan TX TM],
        ["Turks and Caicos Islands", "TK", "TC"],
        %w[Ukraine UP UA],
        ["United Kingdom", "UK", "GB"],
        %w[Vanuatu NH VU],
        ["Viet Nam", "VM", "VN"],
        ["Virgin Islands, British", "VI", "VG"],
        ["Virgin Islands, U.S.", "VQ", "VI"],
        ["Western Sahara", "WI", "EH"],
        %w[Yemen YM YE],
        %w[Zambia ZA ZM],
        %w[Zimbabwe ZI ZW],
        ["United States", "USA", "US"]
      ]

      addresses_to_update = []

      # e.g. convert AS -> AU and Australia -> AU
      # SELECT "addresses".* FROM "addresses"
      #    WHERE (("addresses"."country" = 'AU' OR "addresses"."country" = 'Australia'))
      convert_table.each do |ct|
        table = Address.arel_table
        scope = table[:country].eq(ct[0]) # Australia
        scope = scope.or(table[:country].eq(ct[1])) # AU

        tmp = Address.where(scope)
        tmp.map { |t| t.country = ct[2] }

        addresses_to_update << tmp unless tmp.blank?
      end

      Address.transaction do
        begin
          addresses_to_update.each do |address_arr|
            address_arr.each(&:save!)
          end
          Setting.have_run_country_migration = true
        rescue Exception => e
          puts e
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
