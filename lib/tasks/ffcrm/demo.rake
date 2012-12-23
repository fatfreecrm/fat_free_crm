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
      # Load fixtures
      require 'active_record/fixtures'
      Dir.glob(FatFreeCRM.root.join('db', 'demo', '*.{yml,csv}')).each do |fixture_file|
        ActiveRecord::Fixtures.create_fixtures(FatFreeCRM.root.join('db/demo'), File.basename(fixture_file, '.*'))
      end

      def create_version(options)
        version = Version.new
        options.each { |k,v| version.send(k.to_s + '=', v) }
        version.save!
      end

      # Simulate random user activities.
      $stdout.sync = true
      puts "Generating user activities..."
      %w(Account Address Campaign Comment Contact Email Lead Opportunity Task).map do |model|
        model.constantize.all
      end.flatten.each do |item|
        user = if item.respond_to?(:user)
          item.user
        elsif item.respond_to?(:addressable)
          item.addressable.try(:user)
        end
        related = if item.respond_to?(:addressable)
          item.addressable
        elsif item.respond_to?(:commentable)
          item.commentable
        elsif item.respond_to?(:mediator)
          item.mediator
        end
        # Backdate within the last 30 days
        created_at = item.created_at - (rand(30) + 1).days + rand(12 * 60).minutes
        updated_at = created_at + rand(12 * 60).minutes

        create_version(:event => "create", :created_at => created_at, :user => user, :item => item, :related => related)
        create_version(:event => "update", :created_at => updated_at, :user => user, :item => item, :related => related)

        if [Account, Campaign, Contact, Lead, Opportunity].include?(item.class)
          viewed_at = created_at + rand(12 * 60).minutes
          version = create_version(:event => "view", :created_at => viewed_at, :user => user, :item => item)
        end
        print "." if item.id % 10 == 0
      end
      puts
    end

    desc "Reset the database and reload demo data along with default application settings"
    task :reload => :environment do
      Rake::Task["db:migrate:reset"].invoke
      Rake::Task["ffcrm:demo:load"].invoke
    end

  end
end
