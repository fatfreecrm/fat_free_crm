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

namespace :ffcrm do
  namespace :data do
    
    desc "add people to mailing lists"
    task :chimp_setup => :environment do
      
      campuses = ["Adelaide", "City East", "City West"]
      
      campuses.each do |campus|
        a = Account.find_by_name(campus)
        a.contacts.each do |c|
          current_string = c.cf_weekly_emails[0]
          new_string = current_string.blank? ? campus : current_string + ", #{campus}"
          c.cf_weekly_emails[0] = new_string unless c.cf_weekly_emails.include?(campus) || c.email.blank?
          c.delay.add_or_update_chimp(campus.parameterize.underscore.to_sym)
          c.save
          puts "added #{c.full_name} to #{campus} weekly emails"
        end
      end
    end
  end
end
