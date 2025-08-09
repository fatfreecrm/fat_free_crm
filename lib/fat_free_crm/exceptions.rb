# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCRM
  class MissingSettings < StandardError; end

  class ObsoleteSettings < StandardError; end
end

class ActionController::Base
  rescue_from FatFreeCRM::MissingSettings,  with: :render_fat_free_crm_exception
  rescue_from FatFreeCRM::ObsoleteSettings, with: :render_fat_free_crm_exception

  private

  def render_fat_free_crm_exception(exception)
    logger.error exception.inspect
    render layout: false, template: "/layouts/500", format: :html, status: 500, locals: { exception: exception }
  end
end
