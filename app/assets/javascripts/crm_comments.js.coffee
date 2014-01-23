# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

(($) ->

  toggleComment = (el) ->
    $container = $(el).closest('div.new_comment')
    baseId  = $container.attr('id').replace('_comment_new', '')
    $post    = $container.find('#' + baseId + '_post')
    $ask     = $container.find('#' + baseId + '_ask')
    $comment = $container.find('#' + baseId + '_comment_comment')
    $post.toggle()
    $ask.toggle()
    if $comment.is(":visible")
      $container.find('form [type=submit]').removeAttr("disabled")
      $container.find('.spinner').hide()
      crm.textarea_user_autocomplete(baseId + '_comment_comment')
      $comment.focus()

  # Show/hide the comment form
  $(document).on 'click', '.new_comment a.cancel, input[name=post_new_note]', ->
    toggleComment(this)

  # When comment form is submitted, disable the form button and show the spinner
  $(document).on 'click', 'div.new_comment [type=submit]', ->
    $(this).attr("disabled", "disabled")
    $(this).prev('.spinner').show()
    $(this).closest('form').submit()

)(jQuery)
