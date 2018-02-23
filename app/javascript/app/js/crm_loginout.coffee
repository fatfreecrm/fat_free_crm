# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  window.crm ||= {}

  #----------------------------------------------------------------------------
  crm.toggle_open_id_login = (first_field = "#authentication_openid_identifier") ->
    $("#login").toggle()
    $("#openid").toggle()
    $("#login_link").toggle()
    $("#openid_link").toggle()
    $(first_field).focus()


  #----------------------------------------------------------------------------
  crm.toggle_open_id_signup = ->
    $("#login").toggle()
    $("#openid").toggle()
    $("#login_link").toggle()
    $("#openid_link").toggle()
    $("#user_email").focus()

) jQuery
