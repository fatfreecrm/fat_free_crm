# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  window.crm ||= {}

  crm.textarea_user_autocomplete = (el_id) ->
    unless $("#areacomplete_" + el_id)[0]
      $("#" + el_id).areacomplete
        wordCount: 1
        mode: "outter"
        on:
          query: (text, cb) ->
            
            # Only autocomplete if search term starts with '@'
            return []  unless text.indexOf("@") is 0
            $.ajax
              url: "/users/auto_complete"
              data:
                term: text.replace("@", "")
              success: (response) ->
                cb response, text.replace("@", "")

          selected: (text, data) ->
            username_regEx = new RegExp("\\((@[^)]+)\\)")
            text.match(username_regEx)[1]
) jQuery
