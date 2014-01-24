# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  # Open list save form
  $(document).on "click", ".lists .list_save a", ->
    $list = $(this).closest('.lists')
    $list.find(".list_form").show().find("[name='list[name]']").focus()
    $list.find(".list_save").hide()
    false

  # Close list save form
  $(document).on "click", ".lists .cancel", ->
    $list = $(this).closest('.lists')
    $list.find(".list_form").hide()
    $list.find(".list_save").show()
    false

  # Set value of hidden list[url] field to serialized search form
  $(document).on "click", ".lists .list_form [type=submit]", ->
    $form = $(this).closest('form')
    $form.find("[name='list[url]']").val(window.location.pathname + '?' + $('form.ransack_search').serialize())
    true

  # Disable submit button when form is submitted
  $(document).on "submit", ".lists .list_form [type=submit]", ->
    $form = $(this).closest('form')
    $form.find("[type=submit]").prop('disabled', true);

  # On li mouseover, change icons to delete buttons
  $(document).on "mouseover", ".lists li", ->
    icon = $(this).find('.delete_on_hover i.fa')
    iconText = crm.get_icon(icon.attr('data-controller'))
    icon.removeClass(iconText).addClass('fa-times-circle')

  # On li mouseout, change asset icons back
  $(document).on "mouseout", ".lists li", ->
    icon = $(this).find('.delete_on_hover i.fa')
    iconText = crm.get_icon(icon.attr('data-controller'))
    icon.removeClass('fa-times-circle').addClass(iconText)

  # On search tab click, toggle list save on/off
  $(document).on 'click', '#search .tabs a', ->
    search_form = $(this).data('search-form')
    switch search_form
      when 'basic_search'
        $('.lists .list_save').hide()
      when 'advanced_search'
        $('.lists .list_save').show()

) jQuery
