(($j) ->

  $j('a[data-view]').live 'click', ->

    if $j(this).data('context') == 'show'
      # replace the '#main' div with the new 'show' contents
      $j.ajax(
        url: $j(this).data('url'),
        dataType: "script"
        data:
          view: $j(this).data('view')
        beforeSend: ->
          $j('#loading').show()
        complete: ->
          $j('#loading').hide()
      )
    else 
      # update the index view by firing off the searches again

      if $j('#search .tabs li a[data-search-form="advanced_search"].active').length == 1
        # handle view change via advanced search form by setting the hidden 'view' field
        $j('#advanced_search_view').remove()
        $j("#advanced_search form input:submit").before('<input id="advanced_search_view" name="view" type="hidden" value="' + $j(this).data('view') + '">')
        $j("#advanced_search form input:submit").click()
      else
        # basic search
        $j.ajax(
          url: $j(this).data('url'),
          type: "POST",
          dataType: "script"
          data:
            view: $j(this).data('view')
            query:   $('query').value
          beforeSend: ->
            $j('#contacts').css({ opacity: 0.4 })
            $j('#loading').show()
          complete: ->
            $j('#contacts').css({ opacity: 1 })
            $j('#loading').hide()
        )

    # TODO: code for when viewing a single contact, not just index
    # need to refresh the page or just the segment

    $j('a[data-view]').removeClass('active')
    $j(this).addClass('active')

) jQuery
