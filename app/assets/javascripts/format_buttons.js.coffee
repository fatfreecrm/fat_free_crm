# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  $(document).on 'click', 'a[data-view]', ->

    if $(this).data('context') == 'show'
      # replace the '#main' div with the new 'show' contents
      $.ajax(
        url: $(this).data('url'),
        dataType: "script"
        data:
          view: $(this).data('view')
        beforeSend: ->
          $('#loading').show()
        complete: ->
          $('#loading').hide()
      )
    else
      # update the index view by firing off the searches again

      if $('#search .tabs li a[data-search-form="advanced_search"].active').length == 1
        # handle view change via advanced search form by setting the hidden 'view' field
        $('#advanced_search_view').remove()
        $("#advanced_search form input:submit").before('<input id="advanced_search_view" name="view" type="hidden" value="' + $(this).data('view') + '">')
        $("#advanced_search form input:submit").click()
      else
        # basic search
        $.ajax(
          url: $(this).data('url'),
          dataType: "script"
          data:
            view: $(this).data('view')
            query: $('#query').val()
          beforeSend: ->
            $('#contacts').css({ opacity: 0.4 })
            $('#loading').show()
          complete: ->
            $('#contacts').css({ opacity: 1 })
            $('#loading').hide()
        )

    # TODO: code for when viewing a single contact, not just index
    # need to refresh the page or just the segment

    $('a[data-view]').removeClass('active')
    $(this).addClass('active')

) jQuery
