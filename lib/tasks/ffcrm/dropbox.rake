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
  namespace :dropbox do
  
    desc "Run dropbox crawler and process incoming emails"
    task :run => :environment do
      require "fat_free_crm/mail_processor/dropbox"
      FatFreeCRM::MailProcessor::Dropbox.new.run(dry_run = false)
    end

    namespace :run do
      desc "[Dry run] - Run dropbox crawler and process incoming emails"
      task :dry => :environment do
        require "fat_free_crm/mail_processor/dropbox"
        FatFreeCRM::MailProcessor::Dropbox.new.run(dry_run = true)
      end
    end

    desc "Set up email dropbox based on currently loaded settings"
    task :setup => :environment do
      require "fat_free_crm/mail_processor/dropbox"
      FatFreeCRM::MailProcessor::Dropbox.new.setup
    end

  end
end
