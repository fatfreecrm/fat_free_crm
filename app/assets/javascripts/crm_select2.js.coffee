# Copyright (c) 2008-2014 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

# Any select box with 'select2' class will be transformed
(($) ->

  window.crm ||= {}

  crm.make_select2 = ->
    $(".select2").not(".select2-container, .select2-offscreen, .select2-hidden-accessible").each ->
      if $(this).data("url")
        $(this).select2
          'width':'resolve'
          placeholder: $(this).attr("placeholder")
          allowClear: true
          ajax:
            url: $(this).data("url")
            dataType: 'json'
      else
        $(this).select2
          'width':'resolve'
          placeholder: $(this).attr("placeholder")
          allowClear: true

      if $(this).prop("disabled") == true
        $(this).next('.select2-container').disable()
        $(this).next('.select2-container').hide()

    $(".select2_tag").not(".select2-container, .select2-offscreen").each ->
      $(this).select2
        'width':'resolve'
        placeholder: $(this).data("placeholder")
        multiple: $(this).data("multiple")
        allowClear: true

  $(document).ready ->
    crm.make_select2()

  $(document).ajaxComplete ->
    crm.make_select2()

) jQuery
