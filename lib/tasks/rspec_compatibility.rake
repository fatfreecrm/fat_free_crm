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

# RSpec 2 seems to have removed the 'spec:db:fixures:load' task. 

namespace :spec do
  namespace :db do
    namespace :fixtures do
      desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
      task :load => :environment do
        require 'active_record/fixtures'
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
        (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(Rails.root, 'spec', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
          ActiveRecord::Fixtures.create_fixtures('spec/fixtures', File.basename(fixture_file, '.*'))
        end
      end
    end
  end
end

