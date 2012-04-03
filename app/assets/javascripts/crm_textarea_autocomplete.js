// Fat Free CRM
// Copyright (C) 2008-2011 by Michael Dvorkin
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
