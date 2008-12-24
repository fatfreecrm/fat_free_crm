var crm = {
  //----------------------------------------------------------------------------
  date_select_popup: function(id) {
    $(id).observe("focus", function() {
      if (!$(id).calendar_was_shown) {    // The field recieved initial focus, show the calendar.
        new CalendarDateSelect(this, { month_year: "label",  year_range: 10, before_close: function() { this.calendar_was_shown = true } });
      } else {
        $(id).calendar_was_shown = null;  // Focus is back from the closed calendar, make it show up again.
      }
    });

    $(id).observe("blur", function() {
      $(id).calendar_was_shown = null;    // Get the calendar ready if we loose focus.
    });
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
  }

}