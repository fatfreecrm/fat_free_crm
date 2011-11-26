// Allows simulation of the 'separator' key-press.
// (Painfully difficult to do in Prototype.)

FacebookList.prototype.fireSeparatorEvent = function() {
  // focus the .maininput li element. This sets the fbtaglist.current variable.
  fbtaglist.focus($$('.bit-input.maininput').first()); 
  var splitOn = this.options.get('separator').value;
  if(this.options.get('newValues')) {
    new_value_el = this.current.retrieveData('input');
    if (!new_value_el.value.endsWith('<')) {
      keep_input = "";
      if (new_value_el.value.indexOf(splitOn) < (new_value_el.value.length - splitOn.length)){
        separator_pos = new_value_el.value.indexOf(splitOn);
        keep_input = new_value_el.value.substr(separator_pos + 1);
        new_value_el.value = new_value_el.value.substr(0,separator_pos).escapeHTML().strip();
      } else {
        new_value_el.value = new_value_el.value.gsub(splitOn,"").escapeHTML().strip();
      }
      if(!this.options.get("spaceReplace").blank()) new_value_el.value.gsub(" ", this.options.get("spaceReplace"));
      if(!new_value_el.value.blank()) {
        this.newvalue = true;
        this.current_input = keep_input.escapeHTML().strip();
        this.autoAdd(new_value_el);
        this.update();
      }
    }
  };
};
