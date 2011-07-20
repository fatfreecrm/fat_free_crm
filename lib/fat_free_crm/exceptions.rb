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
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module FatFreeCRM
  class MissingSettings < StandardError; end
  class ObsoleteSettings < StandardError; end
end

class ActionController::Base
  rescue_from FatFreeCRM::MissingSettings,  :with => :render_fat_free_crm_exception
  rescue_from FatFreeCRM::ObsoleteSettings, :with => :render_fat_free_crm_exception

  private

  def render_fat_free_crm_exception(exception)
    logger.error exception.inspect
    render :layout => false, :template => "/layouts/500.html.haml", :status => 500, :locals => { :exception => exception.to_s.html_safe }
  end
end
