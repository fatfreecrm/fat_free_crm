module AuthenticationsHelper

  def toggle_open_id_login(first_field = "authentication_openid_identifier")
    <<-EOF
    $("login").toggle();
    $("openid").toggle();
    $("login_link").toggle();
    $("openid_link").toggle();
    $("#{first_field}").focus()
    EOF
  end

end
