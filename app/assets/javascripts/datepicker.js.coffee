(($) ->

  $('input.date').live 'click focus', ->
          $(this).datepicker({
            showOn: 'focus',
            changeMonth: true,
            dateFormat: 'dd/mm/yy'})

  $('input.datetime').live 'click focus', ->
    $(this).datetimepicker({
      showOn: 'focus',
      controlType: 'select',
      changeMonth: true,
      dateFormat: 'dd/mm/yy',
      timeFormat: 'hh:mmtt'})
  
) jQuery
