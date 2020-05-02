# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'fat_free_crm/mail_processor/base'

module FatFreeCrm
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
      def process(_uid, email)
        with_subject_line(email) do |entity_name, entity_id|
          create_comment email, entity_name, entity_id
        end
      end

      # Checks the email to detect [entity:id] in the subject.
      #--------------------------------------------------------------------------------------
      def with_subject_line(email)
        if /\[([^:]*):([^\]]*)\]/ =~ email.subject
          entity_name = Regexp.last_match[1]
          entity_id = Regexp.last_match[2]
          # Check that entity is a known model
          if ENTITY_SHORTCUTS.values.include?(entity_name)
            yield entity_name, entity_id
          # Check if entity is a 2 letter 'shortcut'
          elsif expanded_entity = ENTITY_SHORTCUTS[entity_name]
            yield expanded_entity, entity_id
          end
        end
      end

      # Creates a new comment on an entity
      #--------------------------------------------------------------------------------------
      def create_comment(email, entity_name, entity_id)
        # Find entity from subject params
        if (entity = entity_name.capitalize.constantize.find_by_id(entity_id))
          # Create comment if sender has permissions for entity
          if sender_has_permissions_for?(entity)
            parsed_reply = EmailReplyParser.parse_reply(plain_text_body(email))
            Comment.create user:        @sender,
                           commentable: entity,
                           comment:     parsed_reply
          end
        end
      end
    end
  end
end
