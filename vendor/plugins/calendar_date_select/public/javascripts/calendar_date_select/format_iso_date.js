// International date format (ISO 8601): yyyy-mm-dd
// Including time (no seconds): yyyy-mm-dd HH:MM
Date.prototype.toFormattedString = function(include_time) {
        var hour;
    var str = this.getFullYear() + "-" + Date.padded2(this.getMonth() + 1) + "-" +Date.padded2(this.getDate());
    if (include_time) {
        hour = Date.padded2(this.getHours());
        str += " " + hour + ":" + this.getPaddedMinutes();
    }
    return str;
};

// TODO: take care of timezone offsets
// as the timezone is not displayed in the input,
// this could be tricky (or just unnessesary)
Date.parseFormattedString = function (string) {
   var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
                "([T| ]([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
                "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
   var d = string.match(new RegExp(regexp));

   var date = new Date(d[1], 0, 1);

   if (d[3]) { date.setMonth(d[3] - 1); }
   if (d[5]) { date.setDate(d[5]); }
   if (d[7]) { date.setHours(d[7]); }
   if (d[8]) { date.setMinutes(d[8]); }
   return date;
};