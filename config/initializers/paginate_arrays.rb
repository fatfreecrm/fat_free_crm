# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# From https://github.com/mislav/will_paginate/wiki/Backwards-incompatibility
#
#    The Array#paginate method still exists, too, but is not loaded by default.
#    If you need to paginate static arrays, first require it in your code:
#
require 'will_paginate/array'
