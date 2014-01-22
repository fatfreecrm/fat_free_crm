# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  # Initialize chosen for multiselect tag list
  crm.chosen_taglist = (asset, controller, id)->
    $('#' + asset + '_tag_list').chosen(
      allow_option_creation: true
    ).on('change', (event, params = {}) ->
      if tag = params.selected
        crm.load_field_group(controller, tag, id)
      else if tag = params.deselected
        crm.remove_field_group(tag)
    )

  crm.ensure_chosen_account = ->
    unless $("#account_id_chzn").length
      $("#account_id").ajaxChosen(
        allow_single_deselect: true
        show_on_activate: true
        url: "/accounts/auto_complete.json"
        parameters: { limit: 25 }
        query_key: "auto_complete_query"
      )

  # Prefer standard select2 dropdown for non-Ajaxy selectboxes
  add_select2_boxes = ->
    $("select[name*='assigned_to'], select[name*='[country]'], .chzn-select").each ->
      $(this).select2()

    $("select[name*='[user_ids]'], select[name*='[group_ids]']").each ->
      $(this).chosen()

  # Apply pop up to merge links when document is loaded
  $(document).ready ->
    add_select2_boxes()

  # Apply pop up to merge links when jquery event (e.g. search) occurs
  $(document).ajaxComplete ->
    add_select2_boxes()

) jQuery
