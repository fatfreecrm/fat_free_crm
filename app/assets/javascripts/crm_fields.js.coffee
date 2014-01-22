# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  window.crm ||= {}

  #----------------------------------------------------------------------------
  # AJAX loads the form fields for each field group
  crm.load_field_group = (controller, tag, asset_id) ->
    $.get(crm.base_url + "/" + controller + "/field_group", {
      tag: tag
      asset_id: asset_id
      collapsed: "no"
    })


  #----------------------------------------------------------------------------
  # Remove the form fields for the field group with the given tag
  crm.remove_field_group = (tag) ->
    $el = $("#field_groups div[data-tag='" + tag + "']")[0]
    $el.remove()


  #----------------------------------------------------------------------------
  # Fires an 'onclick' event on all '.close' buttons in the DOM.
  # (closes any current edit forms)
  crm.close_all_forms = ->
    $(".close").each (el) ->
      $.get el.href

) jQuery
