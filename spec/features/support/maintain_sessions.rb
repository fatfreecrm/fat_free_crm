# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
#
# Workaround for ActionDispatch::ClosedError
# https://github.com/binarylogic/authlogic/issues/262#issuecomment-1804988
#
User.acts_as_authentic_config[:maintain_sessions] = false
