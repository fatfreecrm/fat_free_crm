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

//----------------------------------------------------------------------------
// AJAX loads the form fields for each field group
crm.load_field_group = function(controller, tag, asset_id) {
  new Ajax.Request(crm.base_url + '/' + controller +'/field_group', {
    asynchronous: true,
    evalScripts: true,
    method: 'get',
    parameters: { tag       : tag,
                  asset_id  : asset_id,
                  collapsed : "no" }
  });
};

//----------------------------------------------------------------------------
// Remove the form fields for the field group with the given tag
crm.remove_field_group = function(tag) {
  el = $$("#field_groups div[data-tag='"+tag+"']")[0];
  if (el) el.remove();
}


//----------------------------------------------------------------------------
// Fires an 'onclick' event on all '.close' buttons in the DOM.
// (closes any current edit forms)
crm.close_all_forms = function() {
  $$('.close').each(function(el){
    new Ajax.Request(el.href, {asynchronous: true, method: "get"})
  });
};
