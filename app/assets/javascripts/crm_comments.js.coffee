# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

# When comments are added to an entity, disable the add button
# and add a spinner to indicate request is processing
(($) ->

  addSpinnerToComments = ->
    $('div.new_comment').each ->
      container = $(this)
      unless container.hasClass('withSpinner')
        container.find('form').on 'submit', ->
          container.find('form [type=submit]').attr("disabled", "disabled")
          container.find('.spinner').show()
        container.addClass("withSpinner")

  toggleComment = (container) ->
    baseId  = container.attr('id').replace('_comment_new', '')
    post    = container.find('#' + baseId + '_post')
    ask     = container.find('#' + baseId + '_ask')
    comment = container.find('#' + baseId + '_comment_comment')
    post.toggle()
    ask.toggle()
    if comment.is(":visible")
      container.find('form [type=submit]').removeAttr("disabled")
      container.find('.spinner').hide()
      comment.focus()

  addOpenCloseToComments = ->
    $('div.new_comment').each ->
      container = $(this)
      unless container.hasClass('withOpenClose')
        baseId = container.attr('id').replace('_comment_new', '')
        post   = container.find('#' + baseId + '_post')
        ask    = container.find('#' + baseId + '_ask')
        container.find('.cancel').on 'click', (event) ->
          toggleComment(container)
          false
        new_comment = container.find('#' + baseId + '_post_new_note')
        new_comment.on 'click', ->
          toggleComment(container)
        crm.textarea_user_autocomplete(baseId + '_comment_comment')
        container.addClass("withOpenClose")

  # Apply when document is loaded
  $(document).ready ->
    addSpinnerToComments()
    addOpenCloseToComments()

  # Apply when jquery event (e.g. search) occurs
  $(document).ajaxComplete ->
    addSpinnerToComments()
    addOpenCloseToComments()

)(jQuery)
