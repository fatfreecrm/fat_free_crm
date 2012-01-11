(($) ->
  class @Search
    constructor: (@templates = {}) ->

    add_fields: (button, type, content) ->
      new_id = new Date().getTime()
      regexp = new RegExp('new_' + type, 'g')
      $(button).closest('p').before(content.replace(regexp, new_id))

    remove_fields: (button) ->
      container = $(button).closest('.fields')
      if (container.siblings().length > 1)
        container.remove()
      else
        container.parent().closest('.fields').remove()

  $(document).ready ->
    search = new Search()

    $(".add_fields").live "click", ->
      search.add_fields this, $(this).data("fieldType"), $(this).data("content")
      false

    $(".remove_fields").live "click", ->
      search.remove_fields this
      false
) jQuery
