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
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

namespace :crm do
  namespace :upgrade do
    desc "Upgrade your database from the Rails 2.x schema to Rails 3"
    task :schema => :environment do
      timestamps = Dir.glob("db/migrate/*.rb").map{|f| File.basename(f)[/(\d+)/,1] }.sort
      timestamps[0..30].each_with_index do |timestamp, i|
        ActiveRecord::Base.connection.
          execute("update schema_migrations set version=#{timestamp} where version=#{i+1};")
      end
    end
  end
end

