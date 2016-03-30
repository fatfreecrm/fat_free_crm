function validateForm() {
    var x = document.forms["new_kiosk"]["kiosk_name"].value;
    if (!/^livelink\d+/i.test(x)) {
        document.getElementById('kiosk_name').style.borderColor = "red";
        alert("Name must begin with 'livelink'");
        return false;
    }
}
