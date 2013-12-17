# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->
  class @Lists
    constructor: (@templates = {}) ->

    show_save_form: ->
      $(".save_list").show()
      $('.save_list #list_name').focus()

    show_save_personal_form: ->
      $(".save_peronal_list").show()
      $('.save_peronal_list #list_name').focus()

    hide_save_form: ->
      $(".save_list").hide()

    hide_save_personal_form: ->
      $(".save_peronal_list").hide()

  $(document).ready ->
    lists = new Lists()

    $(".show_lists_save_form").live "click", ->
      lists.show_save_form()
      $(".show_lists_save_form").hide()
      false

    $(".show_personal_lists_save_form").live "click", ->
      lists.show_save_personal_form()
      $(".show_personal_lists_save_form").hide()
      false

    $(".hide_lists_save_form").live "click", ->
      lists.hide_save_form()
      $(".show_lists_save_form").show()
      false

    $(".hide_lists_save_personal_form").live "click", ->
      lists.hide_save_personal_form()
      $(".show_personal_lists_save_form").show()
      false

    $("input#save_list").live "click", ->
      # Set value of hidden list_url field to serialized search form
      $("#list_url").val(window.location.pathname + '?' + $('form.ransack_search').serialize())
      true

    $("input#save_personal_list").live "click", ->
      # Set value of hidden list_url field to serialized search form
      $("#personal_list_url").val(window.location.pathname + '?' + $('form.ransack_search').serialize())
      true

    # When mouseover on li, change asset icons to delete buttons
    $("#lists li, #personal_lists li").live "mouseover", ->
      icon = $(this).find('.delete_on_hover i.fa')
      iconText = getIcon(icon.attr('data-controller'))
      icon.removeClass(iconText).addClass('fa-times-circle')
    $("#lists li, #personal_lists li").live "mouseout", ->
      icon = $(this).find('.delete_on_hover i.fa')
      iconText = getIcon(icon.attr('data-controller'))
      icon.removeClass('fa-times-circle').addClass(iconText)

    getIcon = (listType) ->
      switch (listType) 
        when "tasks" then "fa-check-square-o"
        when "campaigns" then "fa-bar-chart-o"
        when "leads" then "fa-tasks"
        when "accounts" then "fa-users"
        when "contacts" then "fa-user"
        when "opportunities" then "fa-money"
        when "team" then "fa-globe"

    # When mouseover on li, change asset icons to delete buttons
    $("#personal_lists li").live "mouseover", ->
      img_el = $(this).find('.delete_on_hover img')
      img_el.attr('src', "/assets/delete.png")
    $("#personal_lists li").live "mouseout", ->
      img_el = $(this).find('.delete_on_hover img')
      img_el.attr('src', "/assets/tab_icons/" + img_el.data('controller') + "_active.png")

) jQuery

