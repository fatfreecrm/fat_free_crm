// Fat Free CRM
// Copyright (C) 2008-2009 by Michael Dvorkin
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

if (Object.isUndefined(crm)) { 
  var crm = {};
};

//----------------------------------------------------------------------------
crm.toggle_open_id_login = function(first_field) {
    if (arguments.length == 0) {
      first_field = "authentication_openid_identifier";
    }
    $("login").toggle();
    $("openid").toggle();
    $("login_link").toggle();
    $("openid_link").toggle();
    $(first_field).focus();
  };

//----------------------------------------------------------------------------
crm.toggle_open_id_signup = function() {
    $("login").toggle();
    $("openid").toggle();
    $("login_link").toggle();
    $("openid_link").toggle();
    $('user_email').focus();
  };
