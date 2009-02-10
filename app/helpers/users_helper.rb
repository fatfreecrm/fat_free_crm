module UsersHelper

  def toggle_open_id_signup
    <<-EOF
    $("login").toggle();
    $("openid").toggle();
    $("login_link").toggle();
    $("openid_link").toggle();
    $('user_email').focus()
    EOF
  end

end
