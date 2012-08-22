###
  Fat Free CRM
  Copyright (C) 2008-2011 by Michael Dvorkin

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
  ------------------------------------------------------------------------------
###

(($) ->

  window.toggleCollection = (element, val) ->
    field_collection_string = $(element).parents('table').next().find('.field_collection_string')
    if val
      field_collection_string.show().prev().show().val("Select Options (pipe separated):")
    else
      field_collection_string.hide().prev().hide()

  window.togglePair = (element, val) ->
    customfields = $(element).parents('table').next()
    pairs = $(element).parents('table').next().next()
    if val
      customfields.hide()
      pairs.show()
    else
      customfields.show()
      pairs.hide()

  $('.edit_admin_fields .field_as').live 'change', ->
    switch $(this).val()
      when "select", "multiselect", "check_boxes", "radio"
        toggleCollection(this, true)
        togglePair(this, false)
        break
      when "datepair", "datetimepair"
        toggleCollection(this, false)
        togglePair(this, true)
        break
      else
        toggleCollection(this, false)
        togglePair(this, false)

) jQuery
