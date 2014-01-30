# Copyright (c) 2008-2014 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

# Any select box with 'select2' class will be transformed
(($) ->

  window.crm ||= {}

  crm.make_select2 = ->
    $(".select2").each ->
      $(this).select2 'width':'resolve'

  $(document).ready ->
    crm.make_select2()

  $(document).ajaxComplete ->
    crm.make_select2()

) jQuery
