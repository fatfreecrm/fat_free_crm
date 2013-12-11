# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

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
      arrow = $("#" + id + "_arrow") or $("#arrow")
      arrow.html(@COLLAPSED)
      $("#" + id).hide().html("").css height: "auto"


    #----------------------------------------------------------------------------
    show_form: (id) ->
      arrow = $("#" + id + "_arrow") or $("#arrow")
      arrow.html(@EXPANDED)
      $("#" + id).slideDown(
        250
        ->
          input = $("#" + id).find("input[type=text]")
          input.focus()
      )


    #----------------------------------------------------------------------------
    flip_form: (id) ->
      if $("#" + id + ":visible").length
        @hide_form id
      else
        @show_form id


    #----------------------------------------------------------------------------
    set_title: (id, caption) ->
      title = $("#" + id + "_title") or $("#title")
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
      if $("form").length
        first_element = $("form:input").first()
        if first_element
          first_element.focus()
          first_element.value = first_element.value
      else $("#query").focus()


    # Hide accounts dropdown and show create new account edit field instead.
    #----------------------------------------------------------------------------
    create_account: (and_focus) ->
      crm.ensure_chosen_account()
      $("#account_disabled_title").hide()
      $("#account_select_title").hide()
      $("#account_create_title").show()
      $("#account_id_chzn").hide()
      $("#account_id").disable()
      $("#account_name").enable()
      $("#account_name").clear()
      $("#account_name").show()
      $("#account_name").focus()  if and_focus


    # Hide create account edit field and show accounts dropdown instead.
    #----------------------------------------------------------------------------
    select_account: (and_focus) ->
      crm.ensure_chosen_account()
      $("#account_disabled_title").hide()
      $("#account_create_title").hide()
      $("#account_select_title").show()
      $("#account_name").hide()
      $("#account_name").disable()
      $("#account_id").enable()
      $("#account_id_chzn").show()


    # Show accounts dropdown and disable it to prevent changing the account.
    #----------------------------------------------------------------------------
    select_existing_account: ->
      crm.ensure_chosen_account()
      $("#account_create_title").hide()
      $("#account_select_title").hide()
      $("#account_disabled_title").show()
      $("#account_name").hide()
      $("#account_name").disable()
      
      # Disable chosen account select
      $("#account_id").disable()
      Event.fire $("#account_id"), "liszt:updated"
      $("#account_id_chzn").show()
      
      # Enable hidden account id select so that value is POSTed
      $("#account_id").enable()


    #----------------------------------------------------------------------------
    create_or_select_account: (selector) ->
      if selector isnt true and selector > 0
        @select_existing_account() # disabled accounts dropdown
      else if selector
        @create_account() # create account edit field
      else
        @select_account() # accounts dropdown


    #----------------------------------------------------------------------------
    create_contact: ->
      @clear_all_hints()  if $("#contact_business_address_attributes_country")
      $("#account_assigned_to").val $("contact_assigned_to").val()
      $("#account_id").enable()  if $("#account_id:visible").length


    #----------------------------------------------------------------------------
    save_contact: ->
      @clear_all_hints()  if $("#contact_business_address_attributes_country")
      $("#account_assigned_to").val $("contact_assigned_to").val()

    
    #----------------------------------------------------------------------------
    flip_calendar: (value) ->
      if value is "specific_time"
        $("#task_bucket").toggle() # Hide dropdown.
        $("#task_calendar").toggle() # Show editable date field.
        $("#task_calendar").focus() # Focus to invoke calendar popup.

    
    #----------------------------------------------------------------------------
    flip_campaign_permissions: (value) ->
      if value
        $("#lead_access_campaign").enable()
        $("#lead_access_campaign").checked = 1
        $("#copy_permissions").css color: "#3f3f3f"
      else
        $("#lead_access_campaign").disable()
        $("#copy_permissions").css color: "grey"
        $("#lead_access_private").checked = 1

    
    #----------------------------------------------------------------------------
    flip_subtitle: (el) ->
      $el = $(el)
      arrow = $el.find("small")
      intro = $el.parent().next().find("small")
 
      # Optionally, the intro might be next to the link.
      intro = $el.next("small")  unless intro.length
      section = $el.parent().next().find("div")
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

      for li in $(comment_new_field).siblings("li")
        $li = $(li)
        $a = $li.find("tt a.toggle")
        $dt = $li.find("dt")
        unless typeof (a) is "undefined"
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
      $("#edit_task_" + id + " input[type=\"submit\"]")[0].click()

    
    #----------------------------------------------------------------------------
    flick: (el, action) ->
      $el = $(el)
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
      if arguments_.length is 2
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
      $("#" + from + "_attributes_full_address").val $(to + "_attributes_full_address").val()


    #----------------------------------------------------------------------------
    copy_compound_address: (from, to) ->
      for field in ["street1", "street2", "city", "state zipcode"]
        source = $("#" + from + "_attributes_" + field)
        destination = $("#" + to + "_attributes_" + field)
        @hide_hint destination, source.val()  unless source.attr("hint") is "true"
      
      # Country dropdown needs special treatment ;-)
      $("#" + to + "_attributes_country").val $("#" + from + "_attributes_country").val()
      
      # Update Chosen select
      Event.fire $("#" + to + "_attributes_country"), "liszt:updated"

    
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
      name = controller.capitalize()
      for link in $("#jumpbox_menu a")
        $(link).toggleClass("selected", link.innerHTML is name)

      @auto_complete controller, null, true


    #----------------------------------------------------------------------------
    auto_complete: (controller, related, focus) ->
      if @autocompleter
        Event.stopObserving @autocompleter.element
        delete @autocompleter
      @autocompleter = new Ajax.Autocompleter("auto_complete_query", "auto_complete_dropdown", @base_url + "/" + controller + "/auto_complete",
        frequency: 0.25
        parameters: (if (related) then ("related=" + related) else null)
        onShow: (element, update) ->

          # overridding onShow to include a fix for IE browsers
          # see https://prototype.lighthouseapp.com/projects/8887/tickets/263-displayinline-fixes-positioning-of-autocomplete-results-div-in-ie8
          update.style.display = (if (Prototype.Browser.IE) then "inline" else "absolute")

          # below is default onShow from controls.js
          if not update.style.position or update.style.position is "absolute"
            update.style.position = "absolute"
            Position.clone element, update,
              setHeight: false
              offsetTop: element.offsetHeight

          $(update).fadeIn 150


        # Autocomplete entry found.
        # Attach to related asset.
        # Quick Find: redirect to asset#show.
        # Autocomplete entry not found: refresh current page.
        afterUpdateElement: ((text, el) -> # Binding for this.base_url.
          if el.id
            if related
              new Ajax.Request(@base_url + "/" + related + "/attach",
                method: "put"
                parameters:
                  assets: controller
                  asset_id: escape(el.id)

                onComplete: ->
                  $("#jumpbox").hide()
              )
            else
              window.location.href = @base_url + "/" + controller + "/" + escape(el.id)
          else
            $("#auto_complete_query").val ""
            window.location.href = window.location.href
        ).bind(this)
      )
      $("#auto_complete_dropdown").html ""
      $("#auto_complete_query").value = ""
      $("#auto_complete_query").focus()  if focus

  $ ->
    crm.focus_on_first_field()

    # the element in which we will on all clicks and capture
    # ones originating from pagination links
    container = $(document.body)
    if container
      createSpinner = ->
        $("<img>",
          src: img.src
          class: "spinner"
        )
      img = new Image
      img.src = crm.base_url + "/assets/loading.gif"
      container.on "click", (event) ->
        $el = $(event.target)
        if $el.parent().hasClass("pagination")
          $el.parent(".pagination").html createSpinner()
          $.get $el.attr('href')
          event.preventDefault()
        if $el.parent().hasClass(".per_page_options")
          $el.parent(".per_page_options").html createSpinner()
          $.post $el.attr('href')
          event.preventDefault()


  # Admin Field Tabs
  $(document).on "click", "*[data-tab-class]", (event) ->
    event.preventDefault()
    $el = $(event.target)

    for field in $(".fields")
      $(field).hide()

    for tab in $(".inline_tabs ul li")
      $(tab).removeClass "selected"

    klass = $el.data("tab-class")
    $(klass + "_section").show()
    $el.addClass "selected"

) jQuery
