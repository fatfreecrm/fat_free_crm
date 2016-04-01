// Ensures that the kiosk name is in the correct format ie; livelink70797
function validateForm() {
    var x = document.forms["new_kiosk"]["kiosk_name"].value;
    if (!/^livelink\d+/i.test(x)) {
        document.getElementById('kiosk_name').style.borderColor = "red";
        alert("Name must begin with 'livelink'");
        return false;
    }
}
