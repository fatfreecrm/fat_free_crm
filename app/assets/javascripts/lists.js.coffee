(($) ->
  class @Lists
    constructor: (@templates = {}) ->

    show_save_form: ->
      $(".save_list").show()
      $('.save_list #list_name').focus()

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
      $("#list_url").val(window.location.pathname + '?' + $('form.ransack_search').serialize())
      true

    # When mouseover on li, change asset icons to delete buttons
    $("#lists li").live "mouseover", ->
      img_el = $(this).find('.delete_on_hover img')
      img_el.attr('src', "/assets/delete.png")
    $("#lists li").live "mouseout", ->
      img_el = $(this).find('.delete_on_hover img')
      img_el.attr('src', "/assets/tab_icons/" + img_el.data('controller') + "_active.png")

) jQuery
