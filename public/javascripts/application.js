var crm = {

  EXPANDED:  "&#9660;",
  COLLAPSED: "&#9658;",

  //----------------------------------------------------------------------------
  date_select_popup: function(id, dropdown_id) {
    $(id).observe("focus", function() {
      if (!$(id).calendar_was_shown) {    // The field recieved initial focus, show the calendar.
        var calendar = new CalendarDateSelect(this, { month_year: "label",  year_range: 10, before_close: function() { this.calendar_was_shown = true } });
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
  hide_form: function(id, caption) {
    var title = $(id + "_title") || $("title");
    var arrow = $(id + "_arrow") || $("arrow");
    if (typeof(caption) == "undefined") {
      caption = id.split("_")[1];
      caption = caption.capitalize() + "s";
      if (caption.endsWith("ys")) {
        caption = caption.sub(/ys$/, "ies");
      }
    }
    title.update(caption);
    arrow.update(this.COLLAPSED);
    Effect.BlindUp(id, { duration: 0.25, afterFinish: function() { $(id).update("") } });
  },

  //----------------------------------------------------------------------------
  show_form: function(id, caption) {
    var title = $(id + "_title") || $("title");
    var arrow = $(id + "_arrow") || $("arrow");
    if (typeof(caption) == "undefined") {
      var words = id.split("_");
      caption = words[0].capitalize() + " " + words[1].capitalize();
    }
    title.update(caption);
    arrow.update(this.EXPANDED);
    Effect.BlindDown(id, { duration: 0.25, afterFinish: function() { $(id).down("input[type=text]").focus() } });
  },

  //----------------------------------------------------------------------------
  flip_form: function(id, caption) {
    if ($(id)) {
      if (Element.visible(id)) {
        this.hide_form(id, caption);
      } else {
        this.show_form(id, caption);
      }
    }
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
    }
  },

  // Hide accounts dropdown and show create new account edit field instead.
  //----------------------------------------------------------------------------
  create_account: function(and_focus) {
    $("account_selector").update(" (create new or <a href='#' onclick='crm.select_account(1); return false;'>select existing</a>):");
    $("account_id").hide();
    $("account_id").disable();
    $("account_name").enable();
    $("account_name").show();
    if (and_focus) {
      $("account_name").focus();
    }
  },

  // Hide create account edit field and show accounts dropdown instead.
  //----------------------------------------------------------------------------
  select_account: function(and_focus) {
    $("account_selector").update(" (<a href='#' onclick='crm.create_account(1); return false;'>create new</a> or select existing):");
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
    $("account_selector").update(":");
    $("account_name").hide();
    $("account_name").disable();
    $("account_id").disable();
    $("account_id").show();
  },

  //----------------------------------------------------------------------------
  create_or_select_account: function(selector) {
    console.log("selector: " + selector);
    if (selector !== true && selector > 0) {
      this.select_existing_account(); // disabled accounts dropdown
    } else if (selector) {
      this.create_account();          // create account edit field
    } else {
      this.select_account();          // accounts dropdown
    }
  },

  //----------------------------------------------------------------------------
  flip_calendar: function(value) {
    if (value == "specific_time") {
      $("task_due_at_hint").toggle(); // Hide dropdown.
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
    var arrow = el.down("small");
    var intro = el.up().next().down("small");
    var section = el.up().next().down("div");

    if (Element.visible(section)) {
      arrow.update(this.COLLAPSED);
      Effect.toggle(section, 'slide', { duration: 0.25, afterFinish: function() { intro.toggle(); } });
    } else {
      arrow.update(this.EXPANDED);
      Effect.toggle(section, 'slide', { duration: 0.25, beforeStart: function() { intro.toggle(); } });
    }
  },

  //----------------------------------------------------------------------------
  toggle_open_id_login: function(first_field) {
    if (arguments.length == 0) {
      first_field = "authentication_openid_identifier";
    }
    $("login").toggle();
    $("openid").toggle();
    $("login_link").toggle();
    $("openid_link").toggle();
    $(first_field).focus();
  },

  //----------------------------------------------------------------------------
  toggle_open_id_signup: function() {
    $("login").toggle();
    $("openid").toggle();
    $("login_link").toggle();
    $("openid_link").toggle();
    $('user_email').focus();
  }
}

Event.observe(window, "load", function() { crm.focus_on_first_field() })
