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

var crm = {

  EXPANDED      : "&#9660;",
  COLLAPSED     : "&#9658;",
  request       : null,
  autocompleter : null,
  base_url      : "",

  //----------------------------------------------------------------------------
  date_select_popup: function(id, dropdown_id, show_time) {
    $(id).observe("focus", function() {
      if (!$(id).calendar_was_shown) {    // The field recieved initial focus, show the calendar.
        var calendar = new CalendarDateSelect(this, { month_year: "label",  year_range: 10, time: show_time, before_close: function() { this.calendar_was_shown = true } });
        if (dropdown_id) {
          calendar.buttons_div.build("span", { innerHTML: " | ", className: "button_seperator" });
          calendar.buttons_div.build("a", { innerHTML: "Back to List", href: "#", onclick: function() {
            calendar.close();                   // Hide calendar popup.
            $(id).hide();                       // Hide date edit field.
            $(dropdown_id).show();              // Show dropdown.
            $(dropdown_id).selectedIndex = 0;   // Select first dopdown item.
            $(id).update("");                   // Reset date field value.
            return false;
          }.bindAsEventListener(this) });
        }
      } else {
        $(id).calendar_was_shown = null;  // Focus is back from the closed calendar, make it show up again.
      }
    });

    $(id).observe("blur", function() {
      $(id).calendar_was_shown = null;    // Get the calendar ready if we loose focus.
    });
  },

  //----------------------------------------------------------------------------
  find_form: function(class_name) {
    var forms = $$('form.' + class_name);
    return (forms.length > 0 ? forms[0].id : null);
  },

  //----------------------------------------------------------------------------
  hide_form: function(id) {
    var arrow = $(id + "_arrow") || $("arrow");
    arrow.update(this.COLLAPSED);
    Effect.BlindUp(id, { duration: 0.25, afterFinish: function() { $(id).update("") } });
  },

  //----------------------------------------------------------------------------
  show_form: function(id) {
    var arrow = $(id + "_arrow") || $("arrow");
    arrow.update(this.EXPANDED);
    Effect.BlindDown(id, { duration: 0.25, afterFinish: function() {
        var input = $(id).down("input[type=text]");
        if (input) input.focus();
      }
    });
  },

  //----------------------------------------------------------------------------
  flip_form: function(id) {
    if ($(id)) {
      if (Element.visible(id)) {
        this.hide_form(id);
      } else {
        this.show_form(id);
      }
    }
  },

  //----------------------------------------------------------------------------
  set_title: function(id, caption) {
    var title = $(id + "_title") || $("title");
    if (typeof(caption) == "undefined") {
      var words = id.split("_");
      if (words.length == 1) {
        caption = id.capitalize();
      } else {
        caption = words[0].capitalize() + " " + words[1].capitalize();
      }
    }
    title.update(caption);
  },

  //----------------------------------------------------------------------------
  highlight_off: function(id) {
    $(id).onmouseover = $(id).onmouseout = null;
    $(id).style.background = "white";
  },

  //----------------------------------------------------------------------------
  focus_on_first_field: function() {
    if ($$("form") != "") {
      var first_element = $$("form")[0].findFirstElement();
      if (first_element) {
        first_element.focus();
        first_element.value = first_element.value;
      }
    } else if ($("query")) {
      $("query").focus();
    }
  },

  // Hide accounts dropdown and show create new account edit field instead.
  //----------------------------------------------------------------------------
  create_account: function(and_focus) {
    $("account_disabled_title").hide();
    $("account_select_title").hide();
    $("account_create_title").show();
    $("account_id").hide();
    $("account_id").disable();
    $("account_name").enable();
    $("account_name").clear();
    $("account_name").show();
    if (and_focus) {
      $("account_name").focus();
    }
  },

  // Hide create account edit field and show accounts dropdown instead.
  //----------------------------------------------------------------------------
  select_account: function(and_focus) {
    $("account_disabled_title").hide();
    $("account_create_title").hide();
    $("account_select_title").show();
    $("account_name").hide();
    $("account_name").disable();
    $("account_id").enable();
    $("account_id").show();
    if (and_focus) {
      $("account_id").focus();
    }
  },

  // Show accounts dropdown and disable it to prevent changing the account.
  //----------------------------------------------------------------------------
  select_existing_account: function() {
    $("account_create_title").hide();
    $("account_select_title").hide();
    $("account_disabled_title").show();
    $("account_name").hide();
    $("account_name").disable();
    $("account_id").disable();
    $("account_id").show();
  },

  //----------------------------------------------------------------------------
  create_or_select_account: function(selector) {
    if (selector !== true && selector > 0) {
      this.select_existing_account(); // disabled accounts dropdown
    } else if (selector) {
      this.create_account();          // create account edit field
    } else {
      this.select_account();          // accounts dropdown
    }
  },

  //----------------------------------------------------------------------------
  create_contact: function() {
    if ($("contact_business_address_attributes_country")) {
      this.clear_all_hints();
    }
    $("account_assigned_to").value = $F("contact_assigned_to");
    if ($("account_id").visible()) {
      $("account_id").enable();
    }
  },

  //----------------------------------------------------------------------------
  save_contact: function() {
    if ($("contact_business_address_attributes_country")) {
      this.clear_all_hints();
    }
    $("account_assigned_to").value = $F("contact_assigned_to");
  },

  //----------------------------------------------------------------------------
  flip_calendar: function(value) {
    if (value == "specific_time") {
      $("task_bucket").toggle(); // Hide dropdown.
      $("task_calendar").toggle();    // Show editable date field.
      $("task_calendar").focus();     // Focus to invoke calendar popup.
    }
  },

  //----------------------------------------------------------------------------
  flip_campaign_permissions: function(value) {
    if (value) {
      $("lead_access_campaign").enable();
      $("lead_access_campaign").checked = 1;
      $("copy_permissions").style.color = "#3f3f3f";
    } else {
      $("lead_access_campaign").disable();
      $("copy_permissions").style.color = "grey";
      $("lead_access_private").checked = 1;
    }
  },

  //----------------------------------------------------------------------------
  flip_subtitle: function(el) {
    var arrow = Element.down(el, "small");
    var intro = Element.down(Element.next(Element.up(el)), "small");
    // Optionally, the intro might be next to the link.
    if(!intro){ intro = Element.next(el, "small");};
    var section = Element.down(Element.next(Element.up(el)), "div");

    if (Element.visible(section)) {
      arrow.update(this.COLLAPSED);
      Effect.toggle(section, 'slide', { duration: 0.25, afterFinish: function() { intro.toggle(); } });
    } else {
      arrow.update(this.EXPANDED);
      Effect.toggle(section, 'slide', { duration: 0.25, beforeStart: function() { intro.toggle(); } });
    }
  },

  //----------------------------------------------------------------------------
  flip_note_or_email: function(link, more, less) {
    var body, state;

    if (link.innerHTML == more) {
      body = Element.next(Element.up(link));
      body.hide();
      $(body.id.replace('truncated', 'formatted')).show();  // expand
      link.innerHTML = less;
      state = "Expanded";
    } else {
      body = Element.next(Element.next(Element.up(link)));
      body.hide();
      $(body.id.replace('formatted', 'truncated')).show();  // collapse
      link.innerHTML = more;
      state = "Collapsed";
    }
    // Ex: "formatted_email_42" => [ "formatted", "email", "42" ]
    var arr = body.id.split("_");

    new Ajax.Request(this.base_url + "/home/timeline", {
      method     : "get",
      parameters : { type : arr[1], id : arr[2], state : state }
    });
  },

  //----------------------------------------------------------------------------
  flip_notes_and_emails: function(state, more, less, el_prefix) {
    if(!el_prefix){
      var notes_field  = "shown_notes";
      var emails_field = "shown_emails";
      var comment_new_field = "comment_new";
    } else {
      var notes_field  = el_prefix + "_shown_notes";
      var emails_field = el_prefix + "_shown_emails";
      var comment_new_field = el_prefix + "_comment_new";
    };

    var notes = $(notes_field).value;
    var emails = $(emails_field).value;

    if (notes != "" || emails != "") {
      new Ajax.Request(this.base_url + "/home/timeline", {
        method     : "get",
        parameters : { type : "", id : notes + "+" + emails, state : state },
        onComplete : function() {
          $(comment_new_field).adjacent("li").each( function(li) {
            var a = li.select("tt a.toggle")[0];
            var dt = li.select("dt");
            if (typeof(a) != "undefined") {
              if (state == "Expanded") {
                dt[0].hide();  dt[1].show();
                if (a.innerHTML != less) {
                  a.innerHTML = less;
                }
              } else {
                dt[1].hide();  dt[0].show();
                if (a.innerHTML != more) {
                  a.innerHTML = more;
                }
              }
            }
          }) // each(li)
        }.bind(this) // onComplete
      });
    }
  },

  //----------------------------------------------------------------------------
  reschedule_task: function(id, bucket) {
    $("task_bucket").value = bucket;
    $("edit_task_" + id).onsubmit();
  },

  //----------------------------------------------------------------------------
  flick: function(element, action) {
    if ($(element)) {
      switch(action) {
        case "show":   $(element).show();     break;
        case "hide":   $(element).hide();     break;
        case "clear":  $(element).update(""); break;
        case "remove": $(element).remove();   break;
        case "toggle": $(element).toggle();   break;
      }
    }
  },

  //----------------------------------------------------------------------------
  flash: function(type, sticky) {
    $("flash").hide();
    if (type == "warning" || type == "error") {
      $("flash").className = "flash_warning";
    } else {
      $("flash").className = "flash_notice";
    }
    Effect.Appear("flash", { duration: 0.5 });
    if (!sticky) {
      setTimeout("Effect.Fade('flash')", 3000);
    }
  },

  //----------------------------------------------------------------------------
  show_hint: function(el, hint) {
    if (el.value == '') {
      el.value = hint;
      el.style.color = 'silver'
      el.setAttribute('hint', true);
    }
  },

  //----------------------------------------------------------------------------
  hide_hint: function(el, value) {
    if (arguments.length == 2) {
      el.value = value;
    } else {
      if (el.getAttribute('hint') == "true") {
        el.value = '';
      }
    }
    el.style.color = 'black'
    el.setAttribute('hint', false);
  },

  //----------------------------------------------------------------------------
  clear_all_hints: function() {
    $$("input[hint=true]").each( function(field) {
      field.value = '';
    }.bind(this));
  },

  //----------------------------------------------------------------------------
  copy_address: function(from, to) {
    $(from + "_attributes_full_address").value = $(to + "_attributes_full_address").value;
  },

  //----------------------------------------------------------------------------
  copy_compound_address: function(from, to) {
    $w("street1 street2 city state zipcode").each( function(field) {
      var source = $(from + "_attributes_" + field);
      var destination = $(to + "_attributes_" + field);
      if (source.getAttribute('hint') != "true") {
        this.hide_hint(destination, source.value);
      }
    }.bind(this));

    // Country dropdown needs special treatment ;-)
    $(to + "_attributes_country").selectedIndex = $(from + "_attributes_country").selectedIndex;
  },

  //----------------------------------------------------------------------------
  search: function(query, controller) {
    if (!this.request) {
      var list = controller;          // ex. "users"
      if (list.indexOf("/") >= 0) {   // ex. "admin/users"
        list = list.split("/")[1];
      }
      $("loading").show();
      $(list).setStyle({ opacity: 0.4 });
      new Ajax.Request(this.base_url + "/" + controller + "/search", {
        method     : "get",
        parameters : { query : query },
        onSuccess  : function() {
          $("loading").hide();
          $(list).setStyle({ opacity: 1 });
        },
        onComplete : (function() { this.request = null; }).bind(this)
      });
    }
  },

  //----------------------------------------------------------------------------
  jumper: function(controller) {
    var name = controller.capitalize();
    $$("#jumpbox_menu a").each(function(link) {
      if (link.innerHTML == name) {
        link.addClassName("selected");
      } else {
        link.removeClassName("selected");
      }
    });
    this.auto_complete(controller, null, true);
  },

  //----------------------------------------------------------------------------
  auto_complete: function(controller, related, focus) {
    if (this.autocompleter) {
      Event.stopObserving(this.autocompleter.element);
      delete this.autocompleter;
    }
    this.autocompleter = new Ajax.Autocompleter("auto_complete_query", "auto_complete_dropdown", this.base_url + "/" + controller + "/auto_complete", {
      frequency: 0.25,
      afterUpdateElement: function(text, el) {
        if (el.id) {      // Autocomplete entry found.
          if (related) {  // Attach to related asset.
            new Ajax.Request(this.base_url + "/" + related + "/attach", {
              method     : "put",
              parameters : { assets : controller, asset_id : escape(el.id) },
              onComplete : function() { $("jumpbox").hide(); }
            });
          } else {        // Quick Find: redirect to asset#show.
            window.location.href = this.base_url + "/" + controller + "/" + escape(el.id);
          }
        } else {          // Autocomplete entry not found: refresh current page.
          $("auto_complete_query").value = "";
          window.location.href = window.location.href;
        }
      }.bind(this)        // Binding for this.base_url.
    });
    $("auto_complete_dropdown").update("");
    $("auto_complete_query").value = "";
    if (focus) {
      $("auto_complete_query").focus();
    }
  }
}

document.observe("dom:loaded", function() {
  // the element in which we will observe all clicks and capture
  // ones originating from pagination links
  var container = $(document.body)

  if (container) {
    var img = new Image;
    img.src = '/images/loading.gif';

    function createSpinner() {
      return new Element('img', { src: img.src, 'class': 'spinner' })
    }

    container.observe('click', function(e) {
      var el = e.element();
      if (el.match('.pagination a')) {
        el.up('.pagination').update(createSpinner());
        new Ajax.Request(el.href, { method: 'get' });
        e.stop();
      }
    });
  }
});

// Note: observing "dom:loaded" is supposedly faster that "window.onload" since
// it will fire immediately after the HTML document is fully loaded, but before
// images on the page are fully loaded.

// Event.observe(window, "load", function() { crm.focus_on_first_field() })
document.observe("dom:loaded", function() { crm.focus_on_first_field() });

