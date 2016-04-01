// Finds sites with the 'live' column (column position 2) set to false
// and colours them red
$(document).ready(function () {
    var table = $('#webkiosk_list'),
        rows = table.find('tr'), cells, background, code;        
    for (var i = 1; i < rows.length; i+=1) {
        cells = $(rows[i]).children('td');
        code = $(cells[2]).text();        
        if (code == "false") {
                background = 'rgba(200, 0, 0, 0.7)';
        $(rows[i]).css('background-color', background);
        }
    }
});