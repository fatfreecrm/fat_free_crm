# Copyright (c) 2008-2014 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
(($) ->

  $(document).on 'ajax:send', '.pagination, .per_page_options', ->
    $(this).find('a').prop('disabled', true)
    $(this).closest('#paginate').find('.spinner').show()

  $(document).on 'ajax:complete', '.pagination, .per_page_options', ->
    $(this).find('a').prop('disabled', false)
    $(this).closest('#paginate').find('.spinner').hide()

) jQuery
