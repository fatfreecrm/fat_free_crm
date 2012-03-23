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

require 'fat_free_crm/mail_processor/base'

module FatFreeCRM
  module MailProcessor
    class Dropbox < Base
      KEYWORDS = %w(account campaign contact lead opportunity).freeze

      #--------------------------------------------------------------------------------------
      def initialize
        # Models are autoloaded, so the following @@assets class variable should only be set
        # when Dropbox is initialized. This needs to be done so that Rake tasks such as
        # 'assets:precompile' can run on Heroku without depending on a database.
        # See: http://devcenter.heroku.com/articles/rails31_heroku_cedar#troubleshooting
        @@assets = [ Account, Contact, Lead ].freeze
        @settings = Setting.email_dropbox.dup
        super
      end

      private

      # Email processing pipeline: each steps gets executed if previous one returns false.
      #--------------------------------------------------------------------------------------
      def process(uid, email)
        with_explicit_keyword(email) do |keyword, name|
          data = {"Type" => keyword, "Name" => name}
          find_or_create_and_attach(email, data)
        end and return

        with_recipients(email) do |recipient|
          find_and_attach(email, recipient)
        end and return

        with_forwarded_recipient(email) do |recipient|
          find_and_attach(email, recipient)
        end and return

        with_recipients(email) do |recipient|
          create_and_attach(email, recipient)
        end and return

        with_forwarded_recipient(email) do |recipient|
          create_and_attach(email, recipient)
        end
      end


      # Checks the email to detect keyword on the first line.
      #--------------------------------------------------------------------------------------
      def with_explicit_keyword(email)
        first_line = plain_text_body(email).split("\n").first
        if first_line =~ %r|^[\./]?(#{KEYWORDS.join('|')})\s(.+)$|i
          yield $1.capitalize, $2.strip
        end
      end

      # Checks the email to detect assets on to/bcc addresses
      #--------------------------------------------------------------------------------------
      def with_recipients(email, options = {})
        recipients = []
        recipients += email.to_addrs unless email.to.blank?
        recipients += email.cc_addrs unless email.cc.blank?
        recipients -= [ @settings[:address] ]
        recipients.inject(false) { |attached, recipient| attached ||= yield recipient }
      end

      # Checks the email to detect valid email address in body (first email), detect forwarded emails
      #----------------------------------------------------------------------------------------
      def with_forwarded_recipient(email, options = {})
        if plain_text_body(email) =~ /\b([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4})\b/
          yield $1
        end
      end

      # Process pipe_separated_data or explicit keyword.
      #--------------------------------------------------------------------------------------
      def find_or_create_and_attach(email, data)
        klass = data["Type"].constantize

        if data["Email"] && klass.new.respond_to?(:email)
          conditions = ['email = ?', data["Email"]]
        elsif klass.new.respond_to?(:first_name)
          first_name, *last_name = data["Name"].split
          conditions = if last_name.empty? # Treat single name as last name.
            [ 'last_name LIKE ?', "%#{first_name}" ]
          else
            [ 'first_name LIKE ? AND last_name LIKE ?', "%#{first_name}", "%#{last_name.join(' ')}" ]
          end
        else
          conditions = ['name LIKE ?', "%#{data["Name"]}%"]
        end

        # Find the asset from deduced conditions
        if asset = klass.where(conditions).first
          if sender_has_permissions_for?(asset)
            attach(email, asset, :strip_first_line)
          else
            log "Sender does not have permissions to attach email to #{data["Type"]} #{data["Email"]} <#{data["Name"]}>"
          end
        else
          log "#{data["Type"]} #{data["Email"]} <#{data["Name"]}> not found, creating new one..."
          asset = klass.create!(default_values(klass, data))
          attach(email, asset, :strip_first_line)
        end
        true
      end

      #----------------------------------------------------------------------------------------
      def find_and_attach(email, recipient)
        attached = false
        @@assets.each do |klass|
          asset = klass.find_by_email(recipient)

          # Leads and Contacts have an alt_email: try it if lookup by primary email has failed.
          if !asset && klass.column_names.include?("alt_email")
            asset = klass.find_by_alt_email(recipient)
          end

          if asset && sender_has_permissions_for?(asset)
            attach(email, asset)
            attached = true
          end
        end
        attached
      end

      #----------------------------------------------------------------------------------------
      def create_and_attach(email, recipient)
        contact = Contact.create!(default_values_for_contact(email, recipient))
        attach(email, contact)
      end

      #----------------------------------------------------------------------------------------
      def attach(email, asset, strip_first_line=false)
        to = email.to.blank? ? nil : email.to.join(", ")
        cc = email.cc.blank? ? nil : email.cc.join(", ")

        email_body = if strip_first_line
          plain_text_body(email).split("\n")[1..-1].join("\n").strip
        else
          plain_text_body(email)
        end

        Email.create(
          :imap_message_id => email.message_id,
          :user            => @sender,
          :mediator        => asset,
          :sent_from       => email.from.first,
          :sent_to         => to,
          :cc              => cc,
          :subject         => email.subject,
          :body            => email_body,
          :received_at     => email.date,
          :sent_at         => email.date
        )
        asset.touch

        if asset.is_a?(Lead) && asset.status == "new"
          asset.update_attribute(:status, "contacted")
        end

        if @settings[:attach_to_account] && asset.respond_to?(:account) && asset.account
          Email.create(
            :imap_message_id => email.message_id,
            :user            => @sender,
            :mediator        => asset.account,
            :sent_from       => email.from.first,
            :sent_to         => to,
            :cc              => cc,
            :subject         => email.subject,
            :body            => email_body,
            :received_at     => email.date,
            :sent_at         => email.date
          )
          asset.account.touch
        end
      end

      #----------------------------------------------------------------------------------------
      def default_values(klass, data)
        data = data.dup
        keyword = data.delete("Type").capitalize

        defaults = {
          :user   => @sender,
          :access => default_access
        }

        case keyword
        when "Account", "Campaign", "Opportunity"
          defaults[:status] = "planned" if keyword == "Campaign"      # TODO: I18n
          defaults[:stage] = "prospecting" if keyword == "Opportunity" # TODO: I18n

        when "Contact", "Lead"
          first_name, *last_name = data.delete("Name").split(' ')
          defaults[:first_name] = first_name
          defaults[:last_name] = (last_name.any? ? last_name.join(" ") : "(unknown)")
          defaults[:status] = "contacted" if keyword == "Lead"        # TODO: I18n
        end

        data.each do |key, value|
          key = key.downcase
          defaults[key.to_sym] = value if klass.new.respond_to?(key + '=')
        end

        defaults
      end

      #----------------------------------------------------------------------------------------
      def default_values_for_contact(email, recipient)
        recipient_local, recipient_domain = recipient.split('@')

        defaults = {
          :user       => @sender,
          :first_name => recipient_local.capitalize,
          :last_name  => "(unknown)",
          :email      => recipient,
          :access     => default_access
        }

        # Search for domain name in Accounts.
        account = Account.where('email like ?', "%#{recipient_domain}").first
        if account
          log "asociating new contact #{recipient} with the account #{account.name}"
          defaults[:account] = account
        else
          log "creating new account #{recipient_domain.capitalize} for the contact #{recipient}"
          defaults[:account] = Account.create!(
            :user   => @sender,
            :email  => recipient,
            :name   => recipient_domain.capitalize,
            :access => default_access
          )
        end
        defaults
      end

      # If default access is 'Shared' then change it to 'Private' because we don't know how
      # to choose anyone to share it with here.
      #--------------------------------------------------------------------------------------
      def default_access
        Setting.default_access == "Shared" ? 'Private' : Setting.default_access
      end


    end
  end
end
