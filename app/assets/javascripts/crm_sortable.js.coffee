# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
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

  $(document).ready ->
    crm.init_sortables()

  $(document).ajaxComplete ->
    crm.init_sortables()

) jQuery
