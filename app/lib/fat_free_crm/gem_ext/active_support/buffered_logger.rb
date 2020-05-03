# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class ActiveSupport::BufferedLogger
  BRIGHT = "\033[1;37;40m"
  NORMAL = "\033[0m"

  def p(*args)
    info "#{BRIGHT}\n\n#{args.join(' ')}#{NORMAL}\n\n\n"
  end

  def i(*args)
    info "#{BRIGHT}\n\n#{args.map(&:inspect).join(' ')}#{NORMAL}\n\n\n"
  end
end
