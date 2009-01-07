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
  create_account: function() {
    $("account_selector").update("(create new or <a href='#' onclick='crm.select_account(); return false;'>select existing</a>):");
    $("account_id").hide();
    $("account_name").show();
    $("account_name").focus();
  },

  //----------------------------------------------------------------------------
  select_account: function() {
    $("account_selector").update("(<a href='#' onclick='crm.create_account(); return false;'>create new</a> or select existing):");
    $("account_id").show();
    $("account_name").hide();
    $("account_id").focus();
  }


}