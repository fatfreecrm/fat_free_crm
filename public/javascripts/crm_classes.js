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
    }, arguments[0] || {});

    this.popup = $(this.options.target);      // actual popup div.

    this.setup_toggle_observer();
    this.setup_hide_observer();
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
  show_popup: function(e) {
    e.stop();
    this.popup.setStyle({ zIndex: this.options.zindex });

    // Add custom "trigger" attribute to the popup div so we could check who has triggered it.
    this.popup.writeAttribute("trigger", this.options.trigger);

    this.options.before_show(e);
    if (!this.options.appear) {
      this.popup.show();
      this.set_position(e);
      this.options.after_show(e);
    } else {
      this.popup.show();
      this.set_position(e);
      this.popup.hide();
      Effect.Appear(this.popup, { duration: this.options.appear, afterFinish: function(e) { this.options.after_show(e); }.bind(this) });
    }
  },

  //----------------------------------------------------------------------------
  toggle_popup: function(e) {
    if (this.popup.visible()) {
      if (this.options.trigger != this.popup.readAttribute("trigger")) {
        // Currently shown popup was opened by some other trigger: hide it immediately
        // without any fancy callbacks, then show this popup.
        this.popup.hide();
        this.show_popup(e);
      } else {
        this.hide_popup(e);
      }
    } else {
      this.show_popup(e);
    }
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

  set_position: function(e) {
    if (this.options.under) {
      var coordinates = $(this.options.under).viewportOffset();
      var under = $(this.options.under)
      var popup = $(this.popup)
      var y_offset = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop;

      var x = (coordinates[0] + under.offsetWidth - popup.offsetWidth) + "px";
      var y = (coordinates[1] + under.offsetHeight + y_offset) + "px";
      this.popup.setStyle({ left: x, top: y });
    }    
  }

});


crm.Menu = Class.create({

  //----------------------------------------------------------------------------
  initialize: function() {
    this.options = Object.extend({
      trigger     : "menu",                   // #id of the element clicking on which triggers dropdown menu.
      align       : "left",                   // align the menu left or right
      appear      : 0,                        // duration of EffectAppear or 0 for show().
      fade        : 0,                        // duration of EffectFade or 0 for hide().
      width       : 0,                        // explicit menu width if set to non-zero
      zindex      : 100,                      // zIndex value for the popup.
      before_show : Prototype.emptyFunction,  // before show callback.
      before_hide : Prototype.emptyFunction,  // before hide callback.
      after_show  : Prototype.emptyFunction,  // after show callback.
      after_hide  : Prototype.emptyFunction   // after hide callback.
    }, arguments[0] || {});

    this.build_menu();
    this.setup_show_observer();
    this.setup_hide_observer();
  },

  //----------------------------------------------------------------------------
  build_menu: function() {
    var ul = new Element("ul");
    this.options.menu_items.each(function(item) {
      var a = new Element("a", { href: "#", title: item.name });
      if (item.on_select) {
        a = Object.extend(a, { on_select: item.on_select });
      }
      var li = new Element("li").insert(a.observe("click", this.select_menu.bind(this)).update(item.name));
      ul.insert(li);
    }.bind(this));

    this.menu = new Element("div", { className: "menu",  style: "display:none" });
    if (this.options.width) {
      this.menu.setStyle({ width: this.options.width + "px" })
    }
    $(document.body).insert(this.menu.insert(ul).observe("click", Event.stop));
  },

  //----------------------------------------------------------------------------
  setup_hide_observer: function() {
    document.observe("click", function(e) {
      if (this.menu && this.menu.visible()) {
        this.hide_menu();
      }
    }.bind(this));
  },

  //----------------------------------------------------------------------------
  setup_show_observer: function() {
    $(this.options.trigger).observe("click", function(e) {
      if (this.menu && !this.menu.visible()) {
        this.show_menu(e);
      }
    }.bind(this));
  },

  //----------------------------------------------------------------------------
  hide_menu: function(e) {
    this.options.before_hide(e);
    if (!this.options.fade) {
      this.menu.hide();
      this.options.after_hide(e);
    } else {
      Effect.Fade(this.menu, { duration: this.options.fade, afterFinish: function(e) { this.options.after_hide(e); }.bind(this) });
    }
  },

  //----------------------------------------------------------------------------
  show_menu: function(e) {
    e.stop();

    var dimensions = Event.element(e).getDimensions();
    var coordinates = Event.element(e).viewportOffset();
    var x = coordinates[0] + "px";
    var y = coordinates[1] + dimensions.height + "px";
    if (this.options.align == "right") {
      x = (coordinates[0] - (this.options.width - dimensions.width + 1)) + "px";
    }

    this.menu.setStyle({ left: x, top: y }).setStyle({ zIndex: this.options.zindex });

    this.options.before_show(e);
    if (!this.options.appear) {
      this.menu.show();
      this.options.after_show(e);
    } else {
      Effect.Appear(this.menu, { duration: this.options.appear, afterFinish: function(e) { this.options.after_show(e); }.bind(this) });
    }
    this.event = e;
  },

  //----------------------------------------------------------------------------
  select_menu: function(e) {
    e.stop();
    if (e.target.on_select) {
      this.hide_menu();
      e.target.on_select(this.event);
    }
  }
});
