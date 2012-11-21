(($j) ->

  $j('a[data-view]').live 'click', ->

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
        loading:  "$('loading').show()",
        complete: ->
          $('loading').hide();
      )

    # TODO: code for when viewing a single contact, not just index
    # need to refresh the page or just the segment

    $j('a[data-view]').removeClass('active');
    $j(this).addClass('active');

) jQuery
