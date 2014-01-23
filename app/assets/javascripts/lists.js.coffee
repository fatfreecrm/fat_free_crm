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

  $ ->
    lists = new Lists()

    $(document).on "click", ".show_lists_save_form", ->
      lists.show_save_form()
      $(".show_lists_save_form").hide()
      false

    $(document).on "click", ".show_personal_lists_save_form", ->
      lists.show_save_personal_form()
      $(".show_personal_lists_save_form").hide()
      false

    $(document).on "click", ".hide_lists_save_form", ->
      lists.hide_save_form()
      $(".show_lists_save_form").show()
      false

    $(document).on "click", ".hide_lists_save_personal_form", ->
      lists.hide_save_personal_form()
      $(".show_personal_lists_save_form").show()
      false

    $(document).on "click", "input#save_list", ->
      # Set value of hidden list_url field to serialized search form
      $("#list_url").val(window.location.pathname + '?' + $('form.ransack_search').serialize())
      true

    $(document).on "click", "input#save_personal_list", ->
      # Set value of hidden list_url field to serialized search form
      $("#personal_list_url").val(window.location.pathname + '?' + $('form.ransack_search').serialize())
      true

    # When mouseover on li, change asset icons to delete buttons
    $(document).on "mouseover", "#lists li, #personal_lists li", ->
      icon = $(this).find('.delete_on_hover i.fa')
      iconText = getIcon(icon.attr('data-controller'))
      icon.removeClass(iconText).addClass('fa-times-circle')
      
    $(document).on "mouseout", "#lists li, #personal_lists li", ->
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

) jQuery
