# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  window.crm ||= {}

  # The multiselect tag list has listeners to load/remove tag fieldsets
  #----------------------------------------------------------------------------
  crm.chosen_taglist = (asset, controller, id) ->
    $('#' + asset + '_tag_list').chosen(
      allow_option_creation: true
    ).on('change', (event, params = {}) ->
      if tag = params.selected
        $.get(crm.base_url + "/" + controller + "/field_group", {
          tag: tag
          asset_id: id
          collapsed: "no"
        })
      else if tag = params.deselected
        $("#field_groups div[data-tag='" + tag + "']").remove()
    )

) jQuery
