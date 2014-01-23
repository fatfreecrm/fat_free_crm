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
    $("#account_id").ajaxChosen(
      allow_single_deselect: true
      show_on_activate: true
      url: "/accounts/auto_complete.json"
      parameters: { limit: 25 }
      query_key: "auto_complete_query"
      )

) jQuery
