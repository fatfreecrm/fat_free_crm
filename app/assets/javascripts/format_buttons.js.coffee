(($j) ->

  $j('a[data-outline]').live 'click', ->

    if $j('#search .tabs li a[data-search-form="advanced_search"].active').length == 1
      # handle outline change via advanced search form by setting the hidden 'outline' field
      $j('#outline').val($j(this).data('outline'))
      $j("#advanced_search form input:submit").click()
    else
      # basic search
      $j.ajax(
        url: $j(this).data('url'),
        type: "POST",
        dataType: "script"
        data:
          outline: $j(this).data('outline')
          query:   $('query').value
        loading:  "$('loading').show()",
        complete: ->
          $('loading').hide();
      )

    $j('a[data-outline]').removeClass('active');
    $j(this).addClass('active');

) jQuery
