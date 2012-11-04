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

  $('.fields select[name="field[as]"]').live 'change', ->
    $.ajax(
        url: '/admin/fields/subform?' + $(this).parents('form').serialize()
        dataType: 'html'
        context: $(this).closest('form').find('.subform')
        success: (data) ->
          $(this).html(data)
          $(this).find('input').first().focus()
    )

  $('.fields a.create').live 'click', ->
    $('.edit_field').hide()
    field_group = $(this).closest('.field_group')
    field_group.find('.empty').hide()
    field_group.find('.arrow').html(crm.EXPANDED)
    field_group.find('.create_field').slideDown().find('input[name="field[label]"]').focus()
    false

  $('.create_field a.close, .create_field a.cancel').live 'click', ->
    $(this).closest('.create_field').hide()
    $(this).closest('.field_group').find('.empty').show()
    $(this).closest('.field_group').find('.arrow').html(crm.COLLAPSED)
    false

  $('.fields a.edit').live 'click', ->
    $('.edit_field').hide()
    $.ajax(
        url: $(this).attr('href')
        context: $(this).closest('li').find('div.edit_field')
        success: (data) ->
          $(this).replaceWith(data).first().focus()
    )
    false
    
  $('.edit_field a.close, .edit_field a.cancel').live 'click', ->
    $(this).closest('.edit_field').hide()
    false

  false

) jQuery
