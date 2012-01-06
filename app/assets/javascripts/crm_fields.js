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
// Adds the 'on_change' hook for the FacebookList, to AJAX load custom field groups.
crm.set_tag_list_event = function(controller, asset, asset_id) {
  var extra_field_group_options = $H({
      onAdd: function(tag, el){
        // Check that the tag is not being added more than twice (case INSENSITIVE)
        var alreadyAdded = (fbtaglist.bits.values().findAll(function(s){return s.toLowerCase() == tag.toLowerCase() }).length > 1);
        if(alreadyAdded){
          // turn off the onDispose hook for this call to .dispose()
          var onDisposeHook = fbtaglist.options.get('onDispose');
          fbtaglist.options.set('onDispose', function(el){});
          fbtaglist.dispose(el);
          fbtaglist.options.set('onDispose', onDisposeHook);
        } else {
          // load the field group if not already loaded.
          crm.load_field_group(controller, tag, asset_id);
        };
      },
      onDispose: function(tag){
        // remove the field group if it was loaded.
        tag = tag.toLowerCase();
        var form_id = loadedFieldGroups.get(tag);
        if(form_id){
          $(form_id).remove();
          loadedFieldGroups.unset(tag);
        };
      }
  });
  fbtaglist.options.update(extra_field_group_options);
};

//----------------------------------------------------------------------------
// AJAX loads the form fields for each field group
crm.load_field_group = function(controller, tag, asset_id) {
  new Ajax.Request('/'+ controller +'/field_group', {
    asynchronous: true,
    evalScripts: true,
    method: 'get',
    parameters: { tag       : tag,
                  asset_id  : asset_id,
                  collapsed : "no" }
  });
};

//----------------------------------------------------------------------------
// Fires an 'onclick' event on all '.close' buttons in the DOM.
// (closes any current edit forms)
crm.close_all_forms = function() {
  $$('.close').each(function(el){
    new Ajax.Request(el.href, {method: "get"})
  });
};

// Initialize the hash to store which field groups have been loaded.
// {'tag' => 'div element id'}
var loadedFieldGroups = new Hash();
