# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

(($) ->

  #----------------------------------------------------------------------------
  # Custom field tabs switcher
  $(document).on "click", "*[data-tab-class]", (event) ->
    event.preventDefault()
    $el = $(this)

    $(".fields").each ->
      $(this).hide()

    $(".inline_tabs ul li").each ->
      $(this).removeClass "selected"

    klass = $el.data("tab-class")
    $("#" + klass + "_section").show()
    $el.addClass "selected"

  #----------------------------------------------------------------------------
  # Load custom field subform
  $(document).on 'change', '.fields select[name="field[as]"]', ->
    $.ajax(
        url: '/admin/fields/subform?' + $(this).parents('form').serialize()
        dataType: 'html'
        context: $(this).closest('form').find('.subform')
        success: (data) ->
          $(this).html(data)
          $(this).find('input').first().focus()
    )

  #----------------------------------------------------------------------------
  # Open new field form
  $(document).on 'click', '.fields a.create', ->
    $('.edit_field').hide()
    field_group = $(this).closest('.field_group')
    field_group.find('.empty').hide()
    field_group.find('.create .arrow').html(crm.EXPANDED)
    field_group.find('.create_field').slideDown().find('input[name="field[label]"]').focus()
    false

  #----------------------------------------------------------------------------
  # Close new field form
  $(document).on 'click', '.create_field a.close, .create_field a.cancel', ->
    $(this).closest('.create_field').hide()
    $(this).closest('.field_group').find('.create .arrow').html(crm.COLLAPSED)
    false

  #----------------------------------------------------------------------------
  # Edit an existing field
  $(document).on 'click', '.fields a.edit', ->
    $('.edit_field').hide()
    $.ajax(
        url: $(this).attr('href')
        context: $(this).closest('li').find('div.edit_field')
        success: (data) ->
          $(this).replaceWith(data).first().focus()
    )
    false

  #----------------------------------------------------------------------------
  # Close edit field form
  $(document).on 'click', '.edit_field a.close, .edit_field a.cancel', ->
    $(this).closest('.edit_field').hide()
    false

) jQuery
