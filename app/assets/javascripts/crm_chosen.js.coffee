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

  # Initialize any chosen select lists after every Ajax response
  Ajax.Responders.register({
    onComplete: ->
      $j("select[name*='assigned_to'], select[name*='[country]'], .chzn-select").each ->
        unless $j(this).hasClass('chzn-done')
          new Chosen this, { allow_single_deselect: true }
  })

) (jQuery)
