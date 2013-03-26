// Copyright (c) 2008-2013 Michael Dvorkin and contributors.
//
// Fat Free CRM is freely distributable under the terms of MIT license.
// See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
//------------------------------------------------------------------------------
crm.textarea_user_autocomplete = function(el_id) {
  if (! jQuery('#areacomplete_' + el_id)[0]) {
    jQuery('#' + el_id).areacomplete({
      wordCount: 1,
      mode: "outter",
      on: {
        query: function(text,cb) {
          // Only autocomplete if search term starts with '@'
          if (text.indexOf("@") != 0) { return []; }

          var words = [];
          for( var i=0; i < _ffcrm_users.length; i++ ) {
            var name_query = text.replace("@",'').toLowerCase();
            if (_ffcrm_users[i].toLowerCase().indexOf(name_query) != -1 ) {
              words.push(_ffcrm_users[i]);
            }
          }
          cb(words, text.replace("@",''));
        },
        selected: function(text, data) {
          var username_regEx = new RegExp("\\((@[^)]+)\\)");
          return text.match(username_regEx)[1];
        }
      }
    });
  }
}
