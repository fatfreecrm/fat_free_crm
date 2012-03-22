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

require "net/imap"
require "mail"

module FatFreeCRM
  class CommentInbox
  
    #--------------------------------------------------------------------------------------
    def initialize
      @settings = Setting.email_comment_inbox.dup
      @archived, @discarded = 0, 0
    end

    #--------------------------------------------------------------------------------------
    def run
      connect! or return nil
      log "logged in to #{@settings[:server]}..."
      with_new_emails do |uid, email|
        process(uid, email)
        archive(uid)
      end
      expunge!
    ensure
      log "messages processed: #{@archived + @discarded}, archived: #{@archived}, discarded: #{@discarded}."
      disconnect!
    end

    # Setup imap folders in settings.
    #--------------------------------------------------------------------------------------
    def setup
      connect!(:setup => true) or return nil
      folders = [ @settings[:scan_folder] ]
      folders << @settings[:move_to_folder] unless @settings[:move_to_folder].blank?
      folders << @settings[:move_invalid_to_folder] unless @settings[:move_invalid_to_folder].blank?

      # Open (or create) destination folder in read-write mode.
      folders.each do |folder|
        if @imap.list("", folder)
          log "folder #{folder} OK"
        else
          log "folder #{folder} missing, creating..."
          @imap.create(folder)
        end
      end
    rescue => e
      $stderr.puts "setup error #{e.inspect}"
    ensure
      disconnect!
    end

    private

    #--------------------------------------------------------------------------------------
    def with_new_emails
      @imap.uid_search(['NOT', 'SEEN']).each do |uid|
        begin
          email = Mail.new(@imap.uid_fetch(uid, 'RFC822').first.attr['RFC822'])
          log "fetched new message...", email
          if is_valid?(email) && sent_from_known_user?(email)
            yield(uid, email)
          else
            discard(uid)
          end
        rescue Exception => e
          if ["test", "development"].include?(Rails.env)
            $stderr.puts e
            $stderr.puts e.backtrace
          end
          log "error processing email: #{e.inspect}", email
          discard(uid)
        end
      end
    end

    # Email processing pipeline: each steps gets executed if previous one returns false.
    #--------------------------------------------------------------------------------------
    def process(uid, email)
      with_subject_line(email) do |entity_name, entity_id|
        SubscriptionMailer.new_comment(email, entity_name, entity_id)
      end
    end

    # Connects to the IMAP server with the loaded settings
    #------------------------------------------------------------------------------
    def connect!(options = {})
      log "connecting to #{@settings[:server]}..."
      @imap = Net::IMAP.new(@settings[:server], @settings[:port], @settings[:ssl])    
      log "logging in to #{@settings[:server]}..."
      @imap.login(@settings[:user], @settings[:password])
      log "logged in to #{@settings[:server]}, checking folders..."  
      @imap.select(@settings[:scan_folder]) unless options[:setup]
      @imap
    rescue Exception => e
      $stderr.puts "Comment Reply Inbox: could not login to the IMAP server: #{e.inspect}" unless Rails.env == "test"
      nil
    end

    #------------------------------------------------------------------------------
    def expunge!
      if @imap
        # Sends a EXPUNGE command to permanently remove from the currently selected mailbox
        # all messages that have the Deleted flag set.
        @imap.expunge
      end
    end

    #------------------------------------------------------------------------------
    def disconnect!
      if @imap
        @imap.logout
        unless @imap.disconnected?
          @imap.disconnect rescue nil
        end
      end
    end

    # Discard message (not valid) action based on settings
    #------------------------------------------------------------------------------
    def discard(uid)
      if @settings[:move_invalid_to_folder]
        @imap.uid_copy(uid, @settings[:move_invalid_to_folder])
      end
      @imap.uid_store(uid, "+FLAGS", [:Deleted])
      @discarded += 1
    end

    # Archive message (valid) action based on settings
    #------------------------------------------------------------------------------
    def archive(uid)
      if @settings[:move_to_folder]
        @imap.uid_copy(uid, @settings[:move_to_folder])
      end
      @imap.uid_store(uid, "+FLAGS", [:Seen])
      @archived += 1
    end

    #------------------------------------------------------------------------------
    def is_valid?(email)
      valid = email.content_type != "text/html"
      log("not a text message, discarding") unless valid
      valid
    end

    #------------------------------------------------------------------------------
    def sent_from_known_user?(email)
      email_address = email.from.first
      known = !find_sender(email_address).nil?
      log("sent by unknown user #{email_address}, discarding") unless known
      known
    end

    #------------------------------------------------------------------------------
    def find_sender(email_address)
      @sender = User.first(:conditions => [ "(lower(email) = ? OR lower(alt_email) = ?) AND suspended_at IS NULL", email_address.downcase, email_address.downcase ])
    end

    # Checks the email to detect keyword on the first line.
    #--------------------------------------------------------------------------------------
    def with_subject_line(email)
      if /\[(?<entity_name>[^:]*):(?<entity_id>[^\]]*)\]/ =~ email.subject
        yield entity_name, entity_id
      end
    end

    # Centralized logging.
    #--------------------------------------------------------------------------------------
    def log(message, email = nil)
      return if Rails.env == "test"
      puts "Comment Reply Inbox: #{message}"
      puts "  From: #{email.from}, Subject: #{email.subject} (#{email.message_id})" if email
    end

    # Returns the plain-text version of an email, or strips html tags
    # if only html is present.
    #--------------------------------------------------------------------------------------
    def plain_text_body(email)
      parts = email.parts.collect {|c| (c.respond_to?(:parts) && !c.parts.empty?) ? c.parts : c}.flatten
      if parts.empty?
        parts << email
      end
      plain_text_part = parts.detect {|p| p.content_type.include?('text/plain')}
      if plain_text_part.nil?
        # no text/plain part found, assuming html-only email
        # strip html tags and remove doctype directive
        plain_text_body = email.body.to_s.gsub(/<\/?[^>]*>/, "")
        plain_text_body.gsub! %r{^<!DOCTYPE .*$}, ''
      else
        plain_text_body = plain_text_part.body.to_s
      end
      plain_text_body.strip.gsub("\r\n", "\n")
    end

  end
end

