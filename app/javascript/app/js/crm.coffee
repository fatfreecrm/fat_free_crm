# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  String::capitalize = ->
    @[0].toUpperCase() + @.substring(1)

  window.crm =
    EXPANDED: "&#9660;"
    COLLAPSED: "&#9658;"
    searchRequest: null
    autocompleter: null
    base_url: ""
    language: "en-US"

    #----------------------------------------------------------------------------
    find_form: (class_name) ->
      forms = $("form." + class_name)
      (if forms.length > 0 then forms[0].id else null)


    #----------------------------------------------------------------------------
    search_tagged: (query, controller) ->
      $("#query").val(query)
      crm.search query, controller

    #
    #   * remove any duplicate 'facebook-list' elements before running the 'BlindUp' effect.
    #   * (The disappearing facebook-list takes precedence over the newly created facebook-list
    #   * that is being AJAX loaded, and messes up the initialization.. )
    #
    hide_form: (id) ->
      $("#facebook-list").remove()
      arrow = $("#" + id + "_arrow")
      arrow = $("#arrow") unless arrow.length
      arrow.html(@COLLAPSED)
      $("#" + id).hide().html("").css height: "auto"


    #----------------------------------------------------------------------------
    show_form: (id) ->
      arrow = $("#" + id + "_arrow")
      arrow = $("#arrow") unless arrow.length
      arrow.html(@EXPANDED)
      $("#" + id).slideDown(250)
      setTimeout ->
        $("#" + id).find("input[autofocus]").focus()
        0


    #----------------------------------------------------------------------------
    flip_form: (id) ->
      if $("#" + id + ":visible").length
        @hide_form id
      else
        @show_form id


    #----------------------------------------------------------------------------
    set_title: (id, caption) ->
      title = $("#" + id + "_title")
      title = $("#title") unless title.length
      if typeof (caption) is "undefined"
        words = id.split("_")
        if words.length is 1
          caption = id.capitalize()
        else
          caption = words[0].capitalize() + " " + words[1].capitalize()
      title.html caption


    #----------------------------------------------------------------------------
    highlight_off: (id) ->
      el = $("#" + id)
      el.onmouseover = el.onmouseout = null
      el.css background: "white"


    #----------------------------------------------------------------------------
    focus_on_first_field: ->
      first_element = $("form:input[type=text]:first")
      if first_element.length
        first_element.focus()
        first_element.val first_element.val()
      else $("#query").focus()


    # Hide accounts dropdown and show create new account edit field instead.
    #----------------------------------------------------------------------------
    show_create_account: ->
      $("#account_disabled_title").hide()
      $("#account_create_title").show()
      $("#account_select_title").hide()
      $("#account_id").prop('disabled', true)
      $("#account_id").next(".select2-container").disable()
      $("#account_id").next(".select2-container").hide()
      $("#account_name").prop('disabled', false)
      $("#account_name").html ""
      $("#account_name").show()


    # Hide create account edit field and show accounts dropdown instead.
    #----------------------------------------------------------------------------
    show_select_account: ->
      $("#account_disabled_title").hide()
      $("#account_create_title").hide()
      $("#account_select_title").show()
      $("#account_name").hide()
      $("#account_name").prop('disabled', true)
      $("#account_id").prop('disabled', false)
      $("#account_id").next(".select2-container").enable()
      $("#account_id").next(".select2-container").show()


    # Show accounts dropdown and disable it to prevent changing the account.
    #----------------------------------------------------------------------------
    show_disabled_select_account: ->
      $("#account_disabled_title").show()
      $("#account_create_title").hide()
      $("#account_select_title").hide()
      $("#account_name").hide()
      $("#account_name").prop('disabled', true)

      # Disable select2 account select but enable hidden
      # account_id select so that value is POSTed
      $("#account_id").next(".select2-container").disable()
      $("#account_id").next(".select2-container").show()
      $("#account_id").prop('disabled', false)


    #----------------------------------------------------------------------------
    create_or_select_account: (selector) ->
      if selector isnt true and selector > 0
        @show_disabled_select_account() # disabled accounts dropdown
      else if selector
        @show_create_account() # create account edit field
      else
        @show_select_account() # accounts dropdown


    #----------------------------------------------------------------------------
    create_contact: ->
      @clear_all_hints()  if $("#contact_business_address_attributes_country")
      $("#account_assigned_to").val $("contact_assigned_to").val()
      $("#account_id").prop('disabled', false)  if $("#account_id:visible").length


    #----------------------------------------------------------------------------
    save_contact: ->
      @clear_all_hints()  if $("#contact_business_address_attributes_country")
      $("#account_assigned_to").val $("contact_assigned_to").val()


    #----------------------------------------------------------------------------
    flip_calendar: (value) ->
      if value is "specific_time"
        $("#task_bucket").toggle() # Hide dropdown.
        $("#task_calendar").toggle() # Show editable date field.
        $("#task_calendar").datepicker({
          showOn: 'focus',
          changeMonth: true,
          dateFormat: 'yy-mm-dd'}).focus() # Focus to invoke calendar popup.


    #----------------------------------------------------------------------------
    flip_campaign_permissions: (value) ->
      if value
        $("#lead_access_campaign").prop('disabled', false)
        $("#lead_access_campaign").checked = 1
        $("#copy_permissions").css color: "#3f3f3f"
      else
        $("#lead_access_campaign").prop('disabled', true)
        $("#copy_permissions").css color: "grey"
        $("#lead_access_private").checked = 1


    #----------------------------------------------------------------------------
    flip_subtitle: (el) ->
      $el = $(el)
      arrow = $el.find("small")
      intro = $el.parent().next().children("small")

      # Optionally, the intro might be next to the link.
      intro = $el.next("small")  unless intro.length
      section = $el.parent().next().children("div")
      section.slideToggle(
        250
        =>
          arrow.html(if section.css('display') is 'none' then @COLLAPSED else @EXPANDED)
          intro.toggle()
      )


    #----------------------------------------------------------------------------
    flip_note_or_email: (link, more, less) ->
      body = undefined
      state = undefined
      if link.innerHTML is more
        body = $(link).parent().next()
        body.hide()
        $("#" + body.attr('id').replace("truncated", "formatted")).show() # expand
        link.innerHTML = less
        state = "Expanded"
      else
        body = $(link).parent().next().next()
        body.hide()
        $("#" + body.attr('id').replace("formatted", "truncated")).show() # collapse
        link.innerHTML = more
        state = "Collapsed"

      # Ex: "formatted_email_42" => [ "formatted", "email", "42" ]
      arr = body.attr('id').split("_")
      $.get(@base_url + "/home/timeline", {
        type: arr[1]
        id: arr[2]
        state: state
      })


    #----------------------------------------------------------------------------
    flip_notes_and_emails: (state, more, less, el_prefix) ->
      unless el_prefix
        notes_field = "#shown_notes"
        emails_field = "#shown_emails"
        comment_new_field = "#comment_new"
      else
        notes_field = "#" + el_prefix + "_shown_notes"
        emails_field = "#" + el_prefix + "_shown_emails"
        comment_new_field = "#" + el_prefix + "_comment_new"

      $(comment_new_field).siblings("li").each ->
        $li = $(this)
        $a = $li.find("tt a.toggle")
        $dt = $li.find("dt")
        if $a.length
          if state is "Expanded"
            $($dt[0]).hide()
            $($dt[1]).show()
            $a.html(less)
          else
            $($dt[0]).show()
            $($dt[1]).hide()
            $a.html(more)

      notes = $(notes_field).val()
      emails = $(emails_field).val()
      if notes isnt "" or emails isnt ""
        $.post(@base_url + "/home/timeline"
          {
            type: ""
            id: notes + "+" + emails
            state: state
          }
        )


    #----------------------------------------------------------------------------
    reschedule_task: (id, bucket) ->
      $("#task_bucket").val bucket
      $("#edit_task_" + id + " input[type=submit]")[0].click()


    #----------------------------------------------------------------------------
    flick: (id, action) ->
      $el = $("#" + id)
      if $el.length
        switch action
          when "show"
            $el.show()
          when "hide"
            $el.hide()
          when "clear"
            $el.html ""
          when "remove"
            $el.remove()
          when "toggle"
            $el.toggle()


    #----------------------------------------------------------------------------
    flash: (type, sticky) ->
      $el = $("#flash")
      $el.hide()
      if type is "warning" or type is "error"
        $el.addClass "flash_warning"
      else
        $el.addClass "flash_notice"
      $el.fadeIn 500

      setTimeout (-> $el.fadeOut(500)), 3000  unless sticky


    #----------------------------------------------------------------------------
    # Will be deprecated soon: html5 placeholder replaced it on address fields
    show_hint: (el, hint) ->
      $el = $(el)
      if $el.val() is ""
        $el.val hint
        $el.css color: "silver"
        $el.attr "hint", true


    #----------------------------------------------------------------------------
    # Will be deprecated soon: html5 placeholder replaced it on address fields
    hide_hint: (el, value) ->
      $el = $(el)
      if arguments.length is 2
        $el.val value
      else
        $el.val("")  if $el.attr("hint") is "true"
      $el.css color: "black"
      $el.attr "hint", false


    #----------------------------------------------------------------------------
    # Will be deprecated soon: html5 placeholder replaced it on address fields
    clear_all_hints: ->
      for field in $("input[hint=true]")
        $(field).val ""


    #----------------------------------------------------------------------------
    copy_address: (from, to) ->
      $("#" + from + "_attributes_full_address").val $("#" + to + "_attributes_full_address").val()


    #----------------------------------------------------------------------------
    copy_compound_address: (from, to) ->
      for field in ["street1", "street2", "city", "state", "zipcode"]
        source = $("#" + from + "_attributes_" + field)
        destination = $("#" + to + "_attributes_" + field)
        @hide_hint destination, source.val()  unless source.attr("hint") is "true"

      # Country dropdown needs special treatment ;-)
      country = $("#" + from + "_attributes_country").select2("data")
      $("#" + to + "_attributes_country").select2("data", country, true)


    #----------------------------------------------------------------------------
    search: (query, controller) ->
      list = controller # ex. "users"
      # ex. "admin/users"
      list = list.split("/")[1]  if list.indexOf("/") >= 0
      $("#loading").show()
      $list = $(list)
      $list.css opacity: 0.4
      @searchRequest.abort()  if @searchRequest and @searchRequest.readyState isnt -4
      @searchRequest = $.get(
        @base_url + "/" + controller + ".js"
        query: query
        ->
          $("#loading").hide()
          $list.css opacity: 1
          @searchRequest = null
      )


    #----------------------------------------------------------------------------
    jumper: (controller) ->
      name = controller
      $("#jumpbox_menu a").each ->
        $(this).toggleClass("selected", $(this).attr('html-data') is name) #the internal controller name, so this can work with i18

      @auto_complete controller, null, true
      $("#auto_complete_query").focus()


    #----------------------------------------------------------------------------
    auto_complete: (controller, related, focus) ->
      $("#auto_complete_query").autocomplete(
        source: (request, response) =>
          request = {auto_complete_query: request['term'], related: related}
          $.get @base_url + "/" + controller + "/auto_complete.json", request, (data) ->
            response $.map(data.results, (value) ->
              label: value.text
              value: value.id
            )

        # Attach to related asset.
        # Quick Find: redirect to asset#show.
        select: (event, ui) => # Binding for this.base_url.
          event.preventDefault()
          if ui.item
            if related
              $.ajax(@base_url + "/" + related + "/attach", type: 'PUT', data: {
                  assets: controller
                  asset_id: ui.item.value
                }
              ).then ->
                $("#auto_complete_query").val ""
            else
              window.location.href = @base_url + "/" + controller + "/" + ui.item.value

        focus: (event, ui) =>
          event.preventDefault()
          $("#auto_complete_query").val(ui.item.label)
      )

      $.extend $.ui.autocomplete::,
        _renderItem: (ul, item) ->
          term = new RegExp( "(" + @element.val() + ")", "gi" )
          html = item.label.replace(term, "<span class=\"jumpbox-highlight\">$1</span>")
          $("<li></li>").data("item.autocomplete", item).append($("<a></a>").html(html)).appendTo ul

    #----------------------------------------------------------------------------
    # Define different icons for each entity type
    get_icon: (listType) ->
      switch (listType)
        when "tasks" then "fa-check-square-o"
        when "campaigns" then "fa-bar-chart-o"
        when "leads" then "fa-tasks"
        when "accounts" then "fa-users"
        when "contacts" then "fa-user"
        when "opportunities" then "fa-money"
        when "team" then "fa-globe"


  $ ->
    crm.focus_on_first_field()

) jQuery
