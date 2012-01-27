(($) ->
  class @Lists
    constructor: (@templates = {}) ->

    show_save_form: ->
      $(".save_list").show()

    hide_save_form: ->
      $(".save_list").hide()

  $(document).ready ->
    lists = new Lists()

    $(".show_lists_save_form").live "click", ->
      lists.show_save_form()
      $(".show_lists_save_form").hide()
      false

    $(".hide_lists_save_form").live "click", ->
      lists.hide_save_form()
      $(".show_lists_save_form").show()
      false

    $("input#save_list").live "click", ->
      # Set value of hidden list_url field to serialized search form
      $("#list_url").val(window.location.pathname + '?' + $('form.advanced_search').serialize())
      true

) jQuery
