(($) ->

  $.fn.ajaxChosen = (options, callback) ->
    # This will come in handy later.
    select = this
    
    # Load chosen. To make things clear, I have taken the liberty
    # of using the .chzn-autoselect class to specify input elements
    # we want to use with ajax autocomplete.
    this.chosen()
    
    # Now that chosen is loaded normally, we can bootstrap it with
    # our ajax autocomplete code.
    this.next('.chzn-container')
      .find(".search-field > input")
      .bind 'keyup', ->
        # This code will be executed every time the user types a letter
        # into the input form that chosen has created
        
        # Retrieve the current value of the input form
        val = $.trim $(this).attr('value')
        
        # Some simple validation so we don't make excess ajax calls. I am
        # assuming you don't want to perform a search with less than 3
        # characters.
        return false if val.length < 3 or val is $(this).data('prevVal')
        
        # Set the current search term so we don't execute the ajax call if
        # the user hits a key that isn't an input letter/number/symbol
        $(this).data('prevVal', val)
        
        # This is a useful reference for later
        field = $(this)
        
        # I'm assuming that it's ok to use the parameter name `term` to send
        # the form value during the ajax call. Change if absolutely needed.
        options.data = term: val
        
        # If the user provided an ajax success callback, store it so we can
        # call it after our bootstrapping is finished.
        success = undefined
        success ?= options.success
        
        # Create our own callback that will be executed when the ajax call is
        # finished.
        options.success = (data) ->
          # Exit if the data we're given is invalid
          return if not data?
          
          # Go through all of the <option> elements in the <select> and remove
          # ones that have not been selected by the user.
          select.find('option').each -> $(this).remove() if not $(this).is(":selected")
          
          # Send the ajax results to the user callback so we can get an object of
          # value => text pairs to inject as <option> elements.
          items = callback data
          
          # Iterate through the given data and inject the <option> elements into
          # the DOM
          $.each items, (value, text) ->
            $("<option />")
              .attr('value', value)
              .html(text)
              .appendTo(select)
              
          # Tell chosen that the contents of the <select> input have been updated
          # This makes chosen update its internal list of the input data.
          select.trigger("liszt:updated")
          
          # For some reason, the contents of the input field get removed once you
          # call trigger above. Often, this can be very annoying (and can make some
          # searches impossible), so we add the value the user was typing back into
          # the input field.
          field.attr('value', val)
          
          # Finally, call the user supplied callback (if it exists)
          success() if success?
          
        # Execute the ajax call to search for autocomplete data
        $.ajax(options)
)(jQuery)
