(($) ->

  $ ->
    $("#advanced_search").search_form()

    # For advanced search we show a spinner and dim the page when loading results
    # This method undoes that when the results are returned. Ideally, this should
    # be converted to jQuery (using the 'live' method)
    # but we have to move to jquery-ujs first as all ajax events are current
    # registered with prototype
    Event.observe document.body, 'ajax:complete', (e, el) ->
      if e.findElement('.advanced_search')
        $("#loading").hide()
        $("#advanced_search").css('opacity', 1)

    Event.observe document.body, 'ajax:failure', (e, el) ->
      if e.findElement('.advanced_search')
        $('#flash').html('An error occurred whilst trying to search') # no i18n
        crm.flash('error')

) jQuery