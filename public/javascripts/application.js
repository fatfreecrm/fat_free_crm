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
  }

  //----------------------------------------------------------------------------
}