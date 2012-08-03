(($) ->

  $('.datepicker').live 'click focus', ->
    $(this).datepicker({
      showOn: 'focus',
      changeMonth: true,
      dateFormat: $(this).data('datepicker-format') || 'yy-mm-dd'})

  $('.datetimepicker').live 'click focus', ->
    $(this).datetimepicker({
      showOn: 'focus',
      changeMonth: true,
      dateFormat: $(this).data('datetimepicker-format') || 'yy-mm-dd'})

  $('.timepicker').live 'click focus', ->
    $(this).timepicker({
      showOn: 'focus',
      changeMonth: true,
      dateFormat: $(this).data('timepicker-format') || 'HH:MM'})

) jQuery
