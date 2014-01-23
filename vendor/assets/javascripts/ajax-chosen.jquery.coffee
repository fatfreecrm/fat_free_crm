# Thanks to https://raw.github.com/meltingice/ajax-chosen/master/src/ajax-chosen.coffee

do ($ = jQuery) ->

  $.fn.ajaxChosen = (settings = {}, callback, chosenOptions = {}) ->
    defaultOptions =
      minTermLength: 3
      afterTypeDelay: 500
      jsonTermKey: "term"
      keepTypingMsg: "Keep typing..."
      lookingForMsg: "Looking for"

    # This will come in handy later.
    select = @

    chosenXhr = null

    # Merge options with defaults
    options = $.extend {}, defaultOptions, $(select).data(), settings

    # Load chosen. To make things clear, I have taken the liberty
    # of using the .chzn-autoselect class to specify input elements
    # we want to use with ajax autocomplete.
    @chosen(if chosenOptions then chosenOptions else {})

    @each ->
      # Now that chosen is loaded normally, we can bootstrap it with
      # our ajax autocomplete code.
      $(@).next('.chzn-container')
        .find(".search-field > input, .chzn-search > input")
        .bind 'keyup', ->
          # This code will be executed every time the user types a letter
          # into the input form that chosen has created

          # Retrieve the current value of the input form
          untrimmed_val = $(@).val()
          val = $.trim $(@).val()

          # Depending on how much text the user has typed, let them know
          # if they need to keep typing or if we are looking for their data
          msg = if val.length < options.minTermLength then options.keepTypingMsg else options.lookingForMsg + " '#{val}'"
          select.next('.chzn-container').find('.no-results').text(msg)

          # If input text has not changed ... do nothing
          return false if val is $(@).data('prevVal')

          # Set the current search term so we don't execute the ajax call if
          # the user hits a key that isn't an input letter/number/symbol
          $(@).data('prevVal', val)

          # At this point, we have a new term/query ... the old timer
          # is no longer valid.  Clear it.

          # We delay searches by a small amount so that we don't flood the
          # server with ajax requests.
          clearTimeout(@timer) if @timer

          # Some simple validation so we don't make excess ajax calls. I am
          # assuming you don't want to perform a search with less than 3
          # characters.
          return false if val.length < options.minTermLength

          # This is a useful reference for later
          field = $(@)

          # Default term key is `term`.  Specify alternative in options.options.jsonTermKey
          options.data = {} unless options.data?
          options.data[options.jsonTermKey] = val
          options.data = options.dataCallback(options.data) if options.dataCallback?

          # If the user provided an ajax success callback, store it so we can
          # call it after our bootstrapping is finished.
          success = options.success

          # Create our own callback that will be executed when the ajax call is
          # finished.
          options.success = (data) ->
            # Exit if the data we're given is invalid
            return unless data?

            # Go through all of the <option> elements in the <select> and remove
            # ones that have not been selected by the user.  For those selected
            # by the user, add them to a list to filter from the results later.
            selected_values = []
            select.find('option').each ->
              if not $(@).is(":selected")
                $(@).remove()
              else
                selected_values.push $(@).val() + "-" + $(@).text()
            select.find('optgroup:empty').each ->
              $(@).remove()


            # Send the ajax results to the user callback so we can get an object of
            # value => text pairs to inject as <option> elements.
            items = if callback? then callback(data, field) else data


            nbItems = 0

            # Iterate through the given data and inject the <option> elements into
            # the DOM if it doesn't exist in the selector already
            $.each items, (i, element) ->
              nbItems++

              if element.group
                group = select.find("optgroup[label='#{element.text}']")
                group = $("<optgroup />") unless group.size()

                group.attr('label', element.text)
                  .appendTo(select)
                $.each element.items, (i, element) ->
                  if typeof element == "string"
                    value = i;
                    text = element;
                  else
                    value = element.value;
                    text = element.text;
                  if $.inArray(value + "-" + text, selected_values) == -1
                    $("<option />")
                      .attr('value', value)
                      .html(text)
                      .appendTo(group)
              else
                if typeof element == "string"
                  value = i;
                  text = element;
                else
                  value = element.value;
                  text = element.text;
                if $.inArray(value + "-" + text, selected_values) == -1
                  $("<option />")
                    .attr('value', value)
                    .html(text)
                    .appendTo(select)

            if nbItems
              # Tell chosen that the contents of the <select> input have been updated
              # This makes chosen update its internal list of the input data.
              select.trigger("liszt:updated")
            else
              # If there are no results, display the no_results text
              select.data().chosen.no_results_clear()
              select.data().chosen.no_results field.val()

            # Finally, call the user supplied callback (if it exists)
            settings.success(data) if settings.success?

            # For some reason, the contents of the input field get removed once you
            # call trigger above. Often, this can be very annoying (and can make some
            # searches impossible), so we add the value the user was typing back into
            # the input field.
            field.val(untrimmed_val)

            # Because non-ajax Chosen isn't constantly re-building results, when it
            # DOES rebuild results (during liszt:updated above, it clears the input
            # search field before scaling it.  This causes the input field width to be
            # at it's minimum, which is about 25px.

            # The proper way to fix this would be create a new method in chosen for
            # rebuilding results without clearing the input field.  Or to call
            # Chosen.search_field_scale() after resetting the value above.  This isn't
            # possible with the current state of Chosen.  The quick fix is to simply reset
            # the width of the field after we reset the value of the input text.
            # field.css('width','auto')

          # Execute the ajax call to search for autocomplete data with a timer
          @timer = setTimeout ->
            chosenXhr.abort() if chosenXhr
            chosenXhr = $.ajax(options)
          , options.afterTypeDelay
