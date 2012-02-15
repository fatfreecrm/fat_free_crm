# Initialize chosen for multiselect tag list
crm.chosen_taglist = (asset, controller, id)->
  new Chosen $(asset + '_tag_list'), {
    allow_option_creation: true
    on_option_add: (tag) ->
      crm.load_field_group(controller, tag, id)
    on_option_remove: (tag) ->
      crm.remove_field_group(tag)
  }


# Ensures initialization of ajaxChosen account selector
crm.ensure_chosen_account = ->
  unless $("account_id_chzn")
    new ajaxChosen $("account_id"), {
      allow_single_deselect: true
      show_on_activate: true
      url: "/accounts/auto_complete.json"
      parameters: { limit: 25 }
      query_key: "auto_complete_query"
    }


# Initialize chosen select lists for certain fields
crm.init_chosen_fields = ->
  ['assigned_to'].each (field) ->
    $$("select[name*='"+field+"']").each (el) ->
      new Chosen el, { allow_single_deselect: true }
