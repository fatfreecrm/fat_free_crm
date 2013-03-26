# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

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
