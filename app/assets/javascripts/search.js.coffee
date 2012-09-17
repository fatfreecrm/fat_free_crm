(($) ->
  class @Search
    constructor: (@templates = {}) ->

    add_fields: (button, type, content) ->
      new_id = new Date().getTime()
      regexp = new RegExp('new_' + type, 'g')
      $(button).closest('p').before(content.replace(regexp, new_id))

    remove_fields: (button) ->
      container = $(button).closest('.fields')
      if (container.siblings().length > 1)
        container.remove()
      else
        container.parent().closest('.fields').remove()


  $(document).ready ->
    search = new Search()

    $(".add_fields").live "click", ->
      search.add_fields this, $(this).data("fieldType"), $(this).data("content")
      false

    $(".remove_fields").live "click", ->
      search.remove_fields this
      false

    $("select.predicate").live "change", ->
      value_el = $('input#' + $(this).attr('id').slice(0, -1) + "v_0_value")
      if $(this).val() in ["true", "false", "blank", "present", "null", "not_null"]
        value_el.val("true")
        value_el.hide()
      else
        unless value_el.is(":visible")
          value_el.val("")
          value_el.show()

    # show spinner and disable the form when the search is underway
    $("#advanced_search form input:submit").live "click", ->
      $("#loading").show()
      $("#advanced_search").css({ opacity: 0.4 })
      $('div.list').html('')
      true

    # Fire change event for existing search form.
    $("select.predicate").change()


    # Search tabs
    # -----------------------------------------------------
    activate_search_form = (search_form) ->
      # Hide all
      $('#search .search_form').hide()
      $('#search .tabs li a').removeClass('active')
      # Show selected
      $('#' + search_form).show()
      $('a[data-search-form=' + search_form + ']').addClass('active')
      # Run search for current query
      switch search_form
        when 'basic_search'
          query_input = $('#basic_search input#query')
          if !query_input.is('.defaultTextActive')
            value = query_input.val()
          else
            value = ""
          crm.search(value, window.controller)

        when 'advanced_search'
          $("#advanced_search form input:submit").click()

      return
    $("#search .tabs a").click ->
      activate_search_form($(this).data('search-form'))

) jQuery
