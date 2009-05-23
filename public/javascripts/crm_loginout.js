if (Object.isUndefined(crm)) { 
  var crm = {};
};

//----------------------------------------------------------------------------
crm.toggle_open_id_login = function(first_field) {
    if (arguments.length == 0) {
      first_field = "authentication_openid_identifier";
    }
    $("login").toggle();
    $("openid").toggle();
    $("login_link").toggle();
    $("openid_link").toggle();
    $(first_field).focus();
  };

//----------------------------------------------------------------------------
crm.toggle_open_id_signup = function() {
    $("login").toggle();
    $("openid").toggle();
    $("login_link").toggle();
    $("openid_link").toggle();
    $('user_email').focus();
  };
