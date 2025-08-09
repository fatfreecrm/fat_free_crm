# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  # Run function on page load
  $ ->
    $.timeago.settings.allowFuture = true
    
    # our modification to choose correct language
    $.timeago.settings.strings = $.timeago.settings.locales[crm.language]
    $("span.timeago").timeago()
    
    # update every minute
    setInterval (->
      $("span.timeago").timeago()
    ), 60000


  # Run after $ ajax event
  $(document).ajaxComplete ->
    $("span.timeago").timeago()

) jQuery
