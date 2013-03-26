# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  $('input.date').live 'click focus', ->
    $(this).datepicker({
      showOn: 'focus',
      changeMonth: true,
      dateFormat: 'yy-mm-dd'})

  $('input.datetime').live 'click focus', ->
    $(this).datetimepicker({
      showOn: 'focus',
      changeMonth: true,
      dateFormat: 'yy-mm-dd'})

) jQuery
