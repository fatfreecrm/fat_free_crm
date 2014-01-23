# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  window.crm ||= {}

  # Use the 'ajax_chosen' class on select boxes that need to lookup values from server
  # Each select should have a 'data-url' attribute to specify the autocomplete path
  #----------------------------------------------------------------------------
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
