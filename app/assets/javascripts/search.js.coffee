# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  $ ->
    $("#advanced_search").ransack_search_form()

    # For basic search, remove placeholder text on focus, restore on blur
    $('#query').focusin (e) ->
      $(this).data('placeholder', $(this).attr('placeholder')).attr('placeholder', '')
    $('#query').focusout (e) ->
      $(this).attr('placeholder', $(this).data('placeholder'))

    $(document).ajaxComplete ->
      if $('.ransack_search').length
        $("#loading").hide()
        $("#advanced_search").css('opacity', 1)

    # Search tabs
    # -----------------------------------------------------
    activate_search_form = (search_form) ->
      # Hide all
      $('#search .search_form').hide()
      $('#search .tabs li a').removeClass('active')
      # Show selected
      $('#' + search_form).show()
      $('a[data-search-form=' + search_form + ']').addClass('active')
      # Run search for current query
      switch search_form
        when 'basic_search'
          $('#lists .show_lists_save_form').hide()
          $('#personal_lists .show_personal_lists_save_form').hide()
          query_input = $('#basic_search input#query')
          if !query_input.is('.defaultTextActive')
            value = query_input.val()
          else
            value = ""
          crm.search(value, window.controller)
          $('#filters').enable() # Enable filters panel (if present)

        when 'advanced_search'
          $('#lists .show_lists_save_form').show()
          $('#personal_lists .show_personal_lists_save_form').show()
          $("#advanced_search form input:submit").click()
          $('#filters').disable() # Disable filters panel (if present)

      return

    $("#search .tabs a").click ->
      activate_search_form($(this).data('search-form'))

) jQuery
