# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  window.crm ||= {}

  class crm.Popup

    #----------------------------------------------------------------------------
    constructor: (options = {}) ->
      @options = $.extend(
        trigger: "#trigger" # #id of the element that triggers on_mouseover popup.
        target: "#popup" # #id of the popup div that is shown or hidden.
        appear: 0 # duration of EffectAppear or 0 for show().
        fade: 0 # duration of EffectFade or 0 for hide().
        under: false # true to show popup right under the trigger div.
        zindex: 100 # zIndex value for the popup.
        before_show: $.noop # before show callback.
        before_hide: $.noop # before hide callback.
        after_show: $.noop # after show callback.
        after_hide: $.noop # after hide callback.
      , options)
      @popup = $(@options.target) # actual popup div.
      @setup_toggle_observer()
      @setup_hide_observer()


    #----------------------------------------------------------------------------
    setup_toggle_observer: ->
      $(@options.trigger).on "click", (e) =>
        @toggle_popup e


    #----------------------------------------------------------------------------
    setup_hide_observer: ->
      $(document).on "click", (e) =>
        if @popup and @popup.css('display') isnt 'none'
          clicked_on = $(e.target).closest("div")
          @hide_popup e  if clicked_on.length is 0 or ('#' + clicked_on.attr('id')) isnt @options.target


    #----------------------------------------------------------------------------
    show_popup: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @popup.css zIndex: @options.zindex
      
      # Add custom "trigger" attribute to the popup div so we could check who has triggered it.
      @popup.attr trigger: @options.trigger
      @options.before_show e
      unless @options.appear
        @popup.show()
        @set_position e
        @options.after_show e
      else
        @set_position e
        @popup.fadeIn(
          @options.appear
          @options.after_show
        )


    #----------------------------------------------------------------------------
    toggle_popup: (e) ->
      if @popup.filter(':visible').length
        unless @options.trigger is @popup.attr("trigger")
          
          # Currently shown popup was opened by some other trigger: hide it immediately
          # without any fancy callbacks, then show this popup.
          @popup.hide()
          @show_popup e
        else
          @hide_popup e
      else
        @show_popup e


    #----------------------------------------------------------------------------
    hide_popup: (e) ->
      e.preventDefault()  if e
      @options.before_hide e
      unless @options.fade
        @popup.hide()
        @options.after_hide e
      else
        @popup.fadeOut(
          @options.fade
          @options.after_hide
        )

    set_position: (e) ->
      if @options.under
        under = $(@options.under)
        popup = $(@popup)
        offset = under.offset()
        x = (offset.left + under.width() - popup.width()) + "px"
        y = (offset.top + under.height()) + "px"
        @popup.css
          left: x
          top: y



  class crm.Menu

    #----------------------------------------------------------------------------
    constructor: (options = {}) ->
      @options = $.extend(
        trigger: "#menu" # #id of the element clicking on which triggers dropdown menu.
        align: "left" # align the menu left or right
        appear: 0 # duration of EffectAppear or 0 for show().
        fade: 0 # duration of EffectFade or 0 for hide().
        width: 0 # explicit menu width if set to non-zero
        zindex: 100 # zIndex value for the popup.
        before_show: $.noop # before show callback.
        before_hide: $.noop # before hide callback.
        after_show: $.noop # after show callback.
        after_hide: $.noop # after hide callback.
      , options)
      @build_menu()
      @setup_show_observer()
      @setup_hide_observer()


    #----------------------------------------------------------------------------
    build_menu: ->
      @menu = $("<div>",
        class: "menu"
        style: "display:none;";
        on:
          click: (e) ->
            e.preventDefault()
      )
      @menu.css width: @options.width + "px"  if @options.width
      @menu.appendTo(document.body)

      ul = $("<ul>")
      ul.appendTo(@menu)

      for item in @options.menu_items
        li = $("<li>")
        li.appendTo(ul)
        a = $("<a>",
          href: "#"
          title: item.name
          on:
            click: @select_menu.bind(this)
        ).html(item.name)
        a.data(on_select: item.on_select)  if item.on_select
        a.appendTo(li)


    #----------------------------------------------------------------------------
    setup_hide_observer: ->
      $(document).on "click", (e) =>
        @hide_menu(e)  if @menu and @menu.css('display') isnt 'none'


    #----------------------------------------------------------------------------
    setup_show_observer: ->
      $(@options.trigger).on "click", (e) =>
        @show_menu(e)  if @menu and @menu.css('display') is 'none'


    #----------------------------------------------------------------------------
    hide_menu: (e) ->
      @options.before_hide e
      unless @options.fade
        @menu.hide()
        @options.after_hide e
      else
        @menu.fadeOut(
          @options.fade
          @options.after_hide
        )


    #----------------------------------------------------------------------------
    show_menu: (e) ->
      e.preventDefault()
      e.stopPropagation()
      $el = $(e.target)
      offset = $el.offset()
      x = offset.left + "px"
      y = offset.top + $el.height() + "px"
      x = (offset.left - (@options.width - $el.width() + 1)) + "px"  if @options.align is "right"
      @menu.css
        left: x
        top: y
        zIndex: @options.zindex
      @options.before_show e
      unless @options.appear
        @menu.show()
        @options.after_show e
      else
        @menu.fadeIn(
          @options.appear
          @options.after_show
        )

      @event = e


    #----------------------------------------------------------------------------
    select_menu: (e) ->
      e.preventDefault()
      $el = $(e.target)
      if on_select = $el.data('on_select')
        @hide_menu()
        on_select @event

) jQuery
