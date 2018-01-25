# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class UserMailer < ActionMailer::Base
  def assigned_entity_notification(entity, assigner)
    @entity_url = url_for(entity)
    @entity_name = entity.name
    @entity_type = entity.class.name
    @assigner_name = assigner.name
    mail subject: "Fat Free CRM: You have been assigned #{@entity_name} #{@entity_type}",
         to: entity.assignee.email,
         from: from_address
  end

  private

  def from_address
    Setting.dig(:smtp, :from).presence || "Fat Free CRM <noreply@fatfreecrm.com>"
  end
end
