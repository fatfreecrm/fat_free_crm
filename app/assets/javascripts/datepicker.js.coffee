(($) ->

  $('input.date').live 'click focus', ->
    $(this).datepicker({
      showOn: 'focus',
      changeMonth: true,
      dateFormat: 'yy-mm-dd'})

  $('input.datetime').live 'click focus', ->
    $(this).datetimepicker({
      showOn: 'focus',
      changeMonth: true,
      dateFormat: 'yy-mm-dd'})

) jQuery
