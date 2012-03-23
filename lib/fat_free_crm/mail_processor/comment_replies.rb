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

require 'net/imap'
require 'mail'
require 'fat_free_crm/mail_processor/base'

module FatFreeCRM
  module MailProcessor
    class CommentReplies < Base

      # Subject line of email can contain full entity, or shortcuts
      # e.g. [contact:1234] OR [co:1234]
      ENTITY_SHORTCUTS = {
        'ac' => 'account',
        'ca' => 'campaign',
        'co' => 'contact',
        'le' => 'lead',
        'op' => 'opportunity',
        'ta' => 'task'
      }

      #--------------------------------------------------------------------------------------
      def initialize
        @settings = Setting.email_comment_replies.dup
        super
      end

      private

      # Email processing pipeline
      #--------------------------------------------------------------------------------------
      def process(uid, email)
        with_subject_line(email) do |entity_name, entity_id|
          create_comment entity_name, entity_id
        end
      end


      # Checks the email to detect [entity:id] in the subject.
      #--------------------------------------------------------------------------------------
      def with_subject_line(email)
        if /\[(?<entity_name>[^:]*):(?<entity_id>[^\]]*)\]/ =~ email.subject
          # Check that entity is a known model
          if ENTITY_SHORTCUTS.values.include?(entity_name)
            yield entity_name, entity_id
          # Check if entity is a 2 letter 'shortcut'
          elsif expanded_entity = ENTITY_SHORTCUTS[entity_name]
            yield expanded_entity, entity_id
          end
        end
      end

      def create_comment(entity_name, entity_id)
        # Find entity from subject params
        if (entity = entity_name.capitalize.constantize.find_by_id(entity_id))
          # Create comment if sender has permissions for entity
          if sender_has_permissions_for?(entity)
            Comment.create :user        => @sender,
                           :commentable => entity,
                           :comment     => message.body.decoded
          end
        end
      end

      def strip_signatures_and_replies(email)
        e.sub(/On.*wrote:.*\Z/m, '').strip
      end

    end
  end
end

