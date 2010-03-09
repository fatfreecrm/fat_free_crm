# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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
require 'net/imap'
require 'tmail'

module FatFreeCRM
  class Dropbox
    
    def initialize
      @settings = Setting[:email_dropbox]
      connect
    end
    
    def run
      # Loop on not seen emails
      @imap.uid_search(['NOT', 'SEEN']).each do |uid|        
        email = TMail::Mail.parse(@imap.uid_fetch(uid, 'RFC822').first.attr['RFC822'])
        
        unless user = is_valid(email)
          discard(uid)
        else          
          # Is a direct email to dropbox account?
          if email.to.include?(@settings[:dropbox_email])
            p "Is a direct message to dropbox"
          else
            
          end
          require 'ruby-debug'; debugger
          p "Invalid user email #{email.from}"
        end      
        
      end
    end
    
    def connect
      @imap = Net::IMAP.new(@settings[:server], @settings[:port], @settings[:ssl])
      @imap.login(@settings[:user], @settings[:password])
      @imap.select(@settings[:scan_folder])      
    end
    
    def is_valid(email)      
      User.find_by_email(email.from.first.downcase) || nil
    end
    
    def discard(uid)
      if @settings[:move_invalid_to_folder]
        @imap.uid_copy(uid, @settings[:move_invalid_to_folder])   
      end      
      @imap.uid_store(uid, "+FLAGS", [:Deleted])      
    end
    
    def help
      puts "Called from rake task with the following settings"
      p @settings
    end
    

  end # class Dropbox
end # module FatFreeCRM