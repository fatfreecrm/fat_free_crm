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
  namespace :demo do
    desc "Load demo data"
    task :load => :environment do
      # Load fixtures from s
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(FatFreeCRM.root.join('db', 'demo', '*.{yml,csv}'))).each do |fixture_file|
        ActiveRecord::Fixtures.create_fixtures('db/demo', File.basename(fixture_file, '.*'))
      end

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
