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

class UserMailer < ActionMailer::Base

  def password_reset_instructions(user)
    @edit_password_url = edit_password_url(user.perishable_token)

    mail(:subject => "Fat Free CRM: " + I18n.t(:password_reset_instruction),
         :to => user.email,
         :from => "Fat Free CRM <noreply@fatfreecrm.com>",
         :date => Time.now)
  end

end

