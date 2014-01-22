(($) ->
  window.crm ||= {}

  crm.init_sortables = ->
    $('[data-sortable]').each ->
      $el = $(this)

      checkEmpty = ->
        $el.children('.empty').toggle($el.sortable('toArray').length is 1)

      $el.sortable(
        forcePlaceholderSize: true
        connectWith: $el.data('sortable-connect-with')
        handle: $el.data('sortable-handle')
        create: checkEmpty
        update: ->
          ids = []
          for dom_id in $el.sortable('toArray')
            ids.push dom_id.replace(/[^\d]/g, '')
          data = {}
          data[$el.attr('id')] = ids
          $.post($el.attr('data-sortable'), data)
          checkEmpty()
      )

  $ ->
    crm.init_sortables()
) jQuery
