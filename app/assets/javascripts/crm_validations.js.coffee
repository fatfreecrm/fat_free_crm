#------------------------------------------------------------------------------
(($) ->

  # Ensure that any html5 required fields are unhidden when invalid
  #----------------------------------------------------------------------------
  $(document).on 'click', 'form.simple_form input:submit', (event) ->
    form = this.closest('form')
    invalidInputs = form.querySelectorAll(':invalid')
    $(invalidInputs).each ->
      $(this).closest('.field_group').show()

) jQuery