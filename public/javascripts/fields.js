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
crm.load_field_group = function(controller, tags, asset_id) {
  new Ajax.Request('/' + controller + '/field_groups', {
    asynchronous  : true,
    evalScripts:true,
    method:'get',
    parameters: { tags      : tags,
                  asset_id  : asset_id,
                  collapsed : "no" }
  });
};

//----------------------------------------------------------------------------
// Fires an 'onclick' event on all '.close' buttons in the DOM.
// (closes any current edit forms)
crm.close_all_forms = function() {
  $$('.close').each(function(el){el.onclick();});
};

// Initialize the hash to store which field groups have been loaded.
// {'tag' => 'div element id'}
var loadedFieldGroups = new Hash();
