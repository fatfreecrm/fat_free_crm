# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

namespace :ffcrm do
  desc "Generate a secret token for Rails to use."
  task :secret do
    require 'securerandom'
    secret = SecureRandom.hex(64)
    filename = File.join(Rails.root, 'config', 'initializers', 'secret_token.rb')
    File.open(filename, 'w') { |f| f.puts "FatFreeCRM::Application.config.secret_token = '#{secret}'" }
  end
end
