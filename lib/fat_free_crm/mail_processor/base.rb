# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'net/imap'
require 'mail'
require 'email_reply_parser'
require 'premailer'
require 'nokogiri'

module FatFreeCRM
  module MailProcessor
    class Base
      KEYWORDS = %w[account campaign contact lead opportunity].freeze

      #--------------------------------------------------------------------------------------
      def initialize
        @archived = 0
        @discarded = 0
        @dry_run = false
      end

      # Setup imap folders in settings.
      #--------------------------------------------------------------------------------------
      def setup
        log "connecting to #{@settings[:server]}..."
        connect!(setup: true) || (return nil)
        log "logged in to #{@settings[:server]}, checking folders..."
        folders = [@settings[:scan_folder]]
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
      rescue Exception => e
        warn "setup error #{e.inspect}"
      ensure
        disconnect!
      end

      #--------------------------------------------------------------------------------------
      def run(dry_run = false)
        log "Not discarding or archiving any new messages..." if @dry_run = dry_run
        connect! || (return nil)
        with_new_emails do |uid, email|
          # Subclasses must define a #process method that takes arguments: uid, email
          process(uid, email)
          archive(uid)
        end
      ensure
        log "messages processed=#{@archived + @discarded} archived=#{@archived} discarded=#{@discarded}"
        disconnect!
      end

      private

      # Connects to the imap server with the loaded settings
      #------------------------------------------------------------------------------
      def connect!(options = {})
        log "connecting & logging in to #{@settings[:server]}..."
        @imap = Net::IMAP.new(@settings[:server], @settings[:port], @settings[:ssl])
        @imap.login(@settings[:user], @settings[:password])
        log "logged in to #{@settings[:server]}, checking folders..."
        @imap.select(@settings[:scan_folder]) unless options[:setup]
        @imap
      rescue Exception => e
        warn "Could not login to the IMAP server: #{e.inspect}" unless Rails.env == "test"
        nil
      end

      #------------------------------------------------------------------------------
      def disconnect!
        if @imap
          @imap.logout
          unless @imap.disconnected?
            begin
              @imap.disconnect
            rescue Exception
              nil
            end
          end
        end
      end

      #--------------------------------------------------------------------------------------
      def with_new_emails
        @imap.uid_search(%w[NOT SEEN]).each do |uid|
          begin
            email = Mail.new(@imap.uid_fetch(uid, 'RFC822').first.attr['RFC822'])
            log "fetched new message...", email
            if is_valid?(email) && sent_from_known_user?(email)
              yield(uid, email)
            else
              discard(uid)
            end
          rescue Exception => e
            if %w[test development].include?(Rails.env)
              warn e
              warn e.backtrace
            end
            log "error processing email: #{e.inspect}", email
            discard(uid)
          end

          if @dry_run
            log "Marking message as unread"
            @imap.uid_store(uid, "-FLAGS", [:Seen])
          end
        end
      end

      # Discard message (not valid) action based on settings
      #------------------------------------------------------------------------------
      def discard(uid)
        if @dry_run
          log "Not discarding message"
        else
          @imap.uid_copy(uid, @settings[:move_invalid_to_folder]) if @settings[:move_invalid_to_folder]
          @imap.uid_store(uid, "+FLAGS", [:Deleted])
        end
        @discarded += 1
      end

      # Archive message (valid) action based on settings
      #------------------------------------------------------------------------------
      def archive(uid)
        if @dry_run
          log "Not archiving message"
        else
          @imap.uid_copy(uid, @settings[:move_to_folder]) if @settings[:move_to_folder]
          @imap.uid_store(uid, "+FLAGS", [:Seen])
        end
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
        if @sender = User.find_by(
          '(lower(email) = :email OR lower(alt_email) = :email) AND suspended_at IS NULL',
          email: email_address.downcase
        )
          # Set the PaperTrail user for versions (if user is found)
          PaperTrail.request.whodunnit = @sender.id.to_s
        end
      end

      #--------------------------------------------------------------------------------------
      def sender_has_permissions_for?(asset)
        return true if asset.access == "Public"
        return true if asset.user_id == @sender.id || asset.assigned_to == @sender.id
        return true if asset.access == "Shared" && Permission.exists('user_id = ? AND asset_id = ? AND asset_type = ?', @sender.id, asset.id, asset.class.to_s)

        false
      end

      # Centralized logging.
      #--------------------------------------------------------------------------------------
      def log(message, email = nil)
        unless %w[test cucumber].include?(Rails.env)
          klass = self.class.to_s.split("::").last
          klass << " [Dry Run]" if @dry_run
          puts "[#{Time.now.rfc822}] #{klass}: #{message}"
          puts "[#{Time.now.rfc822}] #{klass}: From: #{email.from}, Subject: #{email.subject} (#{email.message_id})" if email
        end
      end

      # Returns the plain-text version of an email, or strips html tags
      # if only html is present.
      #--------------------------------------------------------------------------------------
      def plain_text_body(email)
        # Extract all parts including nested
        parts = if email.multipart?
                  email.parts.map { |p| p.multipart? ? p.parts : p }.flatten
                else
                  charset = email.charset
                  [email]
        end

        if text_part = parts.detect { |p| p.content_type.include?('text/plain') }
          text_body = text_part.body.to_s
          charset = text_part.charset if email.multipart?
        else
          html_part = parts.detect { |p| p.content_type.include?('text/html') } || email
          text_body = Premailer.new(html_part.body.to_s, with_html_string: true).to_plain_text
          charset = html_part.charset if email.multipart?
        end

        # Convert to UTF8 and standardize newline
        clean_invalid_utf8_bytes(text_body.strip.gsub("\r\n", "\n"), charset)
      end

      # Forces the encoding of the given string to UTF8 and replaces invalid characters. This is
      # necessary as emails sometimes have invalid characters like MS "Smart Quotes."
      def clean_invalid_utf8_bytes(text, src_encoding)
        text.encode(
          'UTF-8',
          src_encoding,
          invalid: :replace,
          undef: :replace,
          replace: ''
        )
      end
    end
  end
end
