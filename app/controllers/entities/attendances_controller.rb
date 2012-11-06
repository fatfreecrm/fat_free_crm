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

class AttendancesController < EntitiesController
  
  
  # PUT /tasks/1/complete
  #----------------------------------------------------------------------------
  def mark
    @contact = Contact.find(params[:contact])
    @event_instance = EventInstance.find(params[:event_instance])
    @attendance = new Attendance(:contact => @contact, :event_instance => @event_instance)
    
    @attendance.save

    update_sidebar unless params[:bucket].blank?
    respond_with(@attendance)
  end

  

private

  #----------------------------------------------------------------------------
  alias :get_attendances :get_list_of_records

end
