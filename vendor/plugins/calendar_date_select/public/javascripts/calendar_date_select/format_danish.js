// Formats date and time as "2000/01/20 17:00"
Date.prototype.toFormattedString = function(include_time){
  str = Date.padded2(this.getDate()) + "/" + Date.padded2(this.getMonth() + 1) + "/" + this.getFullYear();

  if (include_time) {
    str += " " + this.getHours() + ":" + this.getPaddedMinutes();
  }
  return str;
}

// Parses date and time as "2000/01/20 17:00"
Date.parseFormattedString = function(string) {
  var regexp = "([0-9]{2})/([0-9]{2})/([0-9]{4})" +
      "( ([0-9]{1,2}):([0-9]{2})(:([0-9]{2})(.([0-9]{3}))?)?" +
      ")?";
  var d = string.match(new RegExp(regexp, "i"));
  if (d==null) return Date.parse(string); // at least give javascript a crack at it.
  var offset = 0;
  var date = new Date(d[3], 0, 1);
  if (d[2]) { date.setMonth(d[2] - 1); }
  if (d[1]) { date.setDate(d[1]); }
  if (d[4]) {
    hours = parseInt(d[5], 10);
    date.setHours(hours);
  }
  if (d[6]) { date.setMinutes(d[6]); }
  //if (d[8]) { date.setSeconds(d[7]); }
  //if (d[9]) { date.setMiliseconds(Number("0." + d[8]) * 1000); }

  return date;
}
