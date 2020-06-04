#
# Converts a select list into a bootstrap button-group with radio button behaviour
#
(($) ->
  $.widget 'ransack.button_group_select',
    options: {}

    _create: ->
      el = @element
      val = el.val()
      el.hide()

      html = '<div class="btn-group btn-group-select" data-toggle="buttons-radio">'
      el.find('option').each (i, o) ->
        html += "<button class=\"btn#{if o.value == val then ' active' else ''}\" type=\"button\" value=\"#{o.value}\">#{o.text}</button>"

      # Insert HTML after hidden select
      el.after html

      # Update select val when button is clicked
      btn_group = el.next()
      btn_group.on 'click', 'button.btn', (e) =>
        @element.val $(e.currentTarget).val()
        true

) jQuery
