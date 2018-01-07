# frozen_string_literal: true

class FixCountryMapping < ActiveRecord::Migration[4.2]
  def up
    message = """ Important note about countries. Please read carefully!

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

Your database settings indicate that you have not run this task before.
Please BACK UP YOUR DATA and then run 'rake ffcrm:update_data:fix_countries'
before continuing any further.

This message will self-destruct in 10 seconds...

"""

    puts message unless Setting.have_run_country_migration
  end

  def down
  end
end
