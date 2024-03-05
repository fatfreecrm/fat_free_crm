# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  # The multiselect tag list has listeners to load/remove fieldsets related to tags
  #----------------------------------------------------------------------------
  $(document).on 'select2:select', "[name*='tag_list']", (event) ->
    url      = $(this).data('url')
    asset_id = $(this).data('asset-id')
    $.get(url, {
      tag: event.params.data.text
      asset_id: asset_id
      collapsed: "no"
    })

  $(document).on 'select2:unselect', "[name*='tag_list']", (event) ->
    $("#field_groups div[data-tag='" + event.params.data.text + "']").remove()

) jQuery
