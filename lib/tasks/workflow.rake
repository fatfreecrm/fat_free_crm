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
  namespace :gonecold do
    desc "Scan for contacts that have gone cold"
    task :find => :environment do
      # Load fixtures
      require 'active_record/fixtures'
      campuses = []
      #campuses << Account.find_by_name("Adelaide Uni")
      campuses << Account.find_by_name("City East")
      campuses << Account.find_by_name("City West")
      campuses -= [nil]
      
      campuses.each do |campus|
        campus.contacts.each do |contact|
          last_time_at_tbt = contact.last_attendance_at_event_category(:bible_talk)
          last_time_at_bsg = contact.last_attendance_at_event_category(:bsg)
          things_missed = []
          things_missed << "TBT" if last_time_at_tbt.nil?
          things_missed << "BSG" if last_time_at_bsg.nil?
          
          if last_time_at_tbt.nil? || last_time_at_bsg.nil? || last_time_at_tbt < (Time.now - 2.weeks) || last_time_at_bsg < (Time.now - 2.weeks)
            if contact.tasks.where('name LIKE (?)', "Has not been at%").empty?
              contact.tasks << Task.new(
                    :user => User.find(1), 
                    :name => "Has not been at #{things_missed.to_sentence(:two_words_connector => " or ")} during the last 2 weeks", 
                    :category => :follow_up, 
                    :bucket => "due_this_week"
                    ) 
              contact.save
              puts "#{contact.first_name} #{contact.last_name} has gone cold on #{things_missed.to_sentence}"
            end
          end
        end
      end  
      puts "Done checking cold contacts"
    end
  end
end
