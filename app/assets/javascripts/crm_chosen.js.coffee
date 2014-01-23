# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  window.crm ||= {}

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

  # Use ajax_chosen for selects that need to lookup values from server
  crm.makeAjaxChosen = ->
    $("select.ajax_chosen").each ->
      $(this).ajaxChosen({
        url: $(this).data('url')
        jsonTermKey: "auto_complete_query",
        minTermLength: 2},
        null,
        {allow_single_deselect: true, show_on_activate: true}
      )

  $(document).ready ->
    crm.makeAjaxChosen()

  $(document).ajaxComplete ->
    crm.makeAjaxChosen()

) jQuery
