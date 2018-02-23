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
            words = []
            i = 0

            while i < _ffcrm_users.length
              name_query = text.replace("@", "").toLowerCase()
              words.push _ffcrm_users[i]  unless _ffcrm_users[i].toLowerCase().indexOf(name_query) is -1
              i++
            cb words, text.replace("@", "")

          selected: (text, data) ->
            username_regEx = new RegExp("\\((@[^)]+)\\)")
            text.match(username_regEx)[1]

) jQuery
