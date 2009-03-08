var crm = {
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
  hide_form: function(id) {
    if ($(id) && Element.visible(id)) {
      var title = id.split("_")[1];
      title = title.capitalize() + "s";
      if (title.endsWith("ys")) {
        title.sub(/ys$/, "ies");
      }
      $(id + "_arrow").update("&#9658;");
      $(id + "_title").update(title);
      Effect.toggle(id, "blind", { duration: 0.25, afterFinish: function() { $(id).update("") } });
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

  //----------------------------------------------------------------------------
  create_account: function() {
    $("account_selector").update("(create new or <a href='#' onclick='crm.select_account(); return false;'>select existing</a>):");
    $("account_id").hide();  $("account_id").disable();
    $("account_name").enable();  $("account_name").show();  $("account_name").focus();
  },

  //----------------------------------------------------------------------------
  select_account: function() {
    $("account_selector").update("(<a href='#' onclick='crm.create_account(); return false;'>create new</a> or select existing):");
    $("account_name").hide();  $("account_name").disable();
    $("account_id").enable();  $("account_id").show();  $("account_id").focus();
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
