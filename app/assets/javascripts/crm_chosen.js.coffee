# Initialize chosen for multiselect tag list
crm.chosen_taglist = (asset, controller, id)->
  new Chosen $(asset + '_tag_list'), {
    allow_option_creation: true
    on_option_add: (tag) ->
      crm.load_field_group(controller, tag, id)
    on_option_remove: (tag) ->
      crm.remove_field_group(tag)
  }

crm.ensure_chosen_account = ->
  unless $("account_id_chzn")
    new ajaxChosen $("account_id"), {
      allow_single_deselect: true
      show_on_activate: true
      url: "/accounts/auto_complete.json"
      parameters: { limit: 25 }
      query_key: "auto_complete_query"
    }

(($j) ->
  
  # Prefer standard select2 dropdown for non-Ajaxy selectboxes
  add_select2_boxes = ->
    $j("select[name*='assigned_to'], select[name*='[country]'], .chzn-select" ).each ->
      $j(this).select2()

  # Apply pop up to merge links when document is loaded
  $j(document).ready ->
    add_select2_boxes()

  # Apply pop up to merge links when jquery event (e.g. search) occurs
  $j(document).ajaxComplete ->
    add_select2_boxes()

  # Apply pop up to merge links when protoype event (e.g. cancel edit) occurs
  Ajax.Responders.register({
    onComplete: ->
      add_select2_boxes()

  })

) (jQuery)