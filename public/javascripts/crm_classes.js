if (Object.isUndefined(crm)) { 
  var crm = {};
};

crm.Popup = Class.create({

  //----------------------------------------------------------------------------
  initialize: function() {
		this.options = Object.extend({
			trigger     : "trigger",                // #id of the element that triggers on_mouseover popup.
      target      : "popup",                  // #id of the popup div that is shown or hidden.
			appear      : 0,                        // duration of EffectAppear or 0 for show().
			fade        : 0,                        // duration of EffectFade or 0 for hide().
			under       : false,                    // true to show popup right under the trigger div.
			zindex      : 100,                      // zIndex value for the popup.
			before_show : Prototype.emptyFunction,  // before show callback.
			before_hide : Prototype.emptyFunction,  // before hide callback.
			after_show  : Prototype.emptyFunction,  // after show callback.
			after_hide  : Prototype.emptyFunction   // after hide callback.
		}, arguments[0] || { });

		this.popup = $(this.options.target);      // actual popup div.

    this.setup_show_observer();
    this.setup_toggle_observer();
    this.setup_hide_observer();
	},

  //----------------------------------------------------------------------------
	setup_show_observer: function() {
		$(this.options.trigger).observe("mouseover", function(e) {
			if (this.popup && !this.popup.visible()) {
			  this.show_popup(e);
		  }
		}.bind(this));
  },

  //----------------------------------------------------------------------------
	setup_toggle_observer: function() {
		$(this.options.trigger).observe("click", function(e) {
		  this.toggle_popup(e);
		}.bind(this));
  },

  //----------------------------------------------------------------------------
	setup_hide_observer: function() {
		document.observe("click", function(e) {
			if (this.popup && this.popup.visible()) {
			  var clicked_on = Event.findElement(e, "div");
			  if (typeof(clicked_on) == "undefined" || clicked_on.id != this.options.target) {
          this.hide_popup(e);
				}
			}
		}.bind(this));
  },

  //----------------------------------------------------------------------------
	hide_popup: function(e) {
		this.options.before_hide(e);
		if (!this.options.fade) {
		  this.popup.hide();
  		this.options.after_hide(e);
		} else {
		  Effect.Fade(this.popup, { duration: this.options.fade, afterFinish: function(e) { this.options.after_hide(e); }.bind(this) });
	  }
  },

  //----------------------------------------------------------------------------
	show_popup: function(e) {
		e.stop();
		if (this.options.under) {
      var dimensions = Event.element(e).getDimensions();
      var coordinates = Event.element(e).viewportOffset();
  		var x = coordinates[0] + "px",
  		    y = coordinates[1] + dimensions.height + "px";

      this.popup.setStyle({ left: x, top: y});
    }
    this.popup.setStyle({ zIndex: this.options.zindex });

		this.options.before_show(e);
		if (!this.options.appear) {
		  this.popup.show();
  		this.options.after_show(e);
		} else {
		  Effect.Appear(this.popup, { duration: this.options.appear, afterFinish: function(e) { this.options.after_show(e); }.bind(this) });
	  }
	},
	
  //----------------------------------------------------------------------------
	toggle_popup: function(e) {
  	if (this.popup) {
  	  this.popup.visible() ? this.hide_popup(e) : this.show_popup(e);
		}
	}
});

document.observe("dom:loaded", function() {
  new crm.Popup({
    trigger     : "jumper",
    target      : "jumpbox",
    appear      : 0.3,
    fade        : 0.3,
    before_show : function() { $("jumper").className = "selected"; },
    after_show  : function() { $("jump_query").focus(); },
    after_hide  : function() { $("jumper").className = ""; }
  });
});
