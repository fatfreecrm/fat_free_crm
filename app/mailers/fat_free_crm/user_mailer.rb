# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCrm
  class UserMailer < ActionMailer::Base
    def assigned_entity_notification(entity, assigner)
      @entity_url = url_for(entity)
      @entity_name = entity.name
      @entity_type = entity.class.name.demodulize
      @assigner_name = assigner.name
      mail subject: "Fat Free CRM: You have been assigned #{@entity_name} #{@entity_type}",
           to: entity.assignee.email,
           from: from_address
    end

    def index_case_notification_to_contact(entity)
      @entity_url = url_for(entity)
      @entity_name = entity.contact.full_name

      mail({subject: "COVID-19 Test Positive", to: entity.contact.email, from: from_address})
    end

    def index_case_notification_to_manager(entity)
      @entity_url = url_for(entity)
      if manager_email.present?
        mail({to: manager_email, subject: "COVID-19 Test Positive", from: from_address}) do |format|
          format.html {render "index_case_notification_to_manager", locals: {index_case: entity}}
        end
      end
    end

    private

    def from_address
      Setting.dig(:smtp, :from).presence || "Fat Free CRM <noreply@fatfreecrm.com>"
    end

    def manager_email
     #TODO need to update to manager of that contact
      "angus.irvine@ideacrew.com"
    end
  end
end
