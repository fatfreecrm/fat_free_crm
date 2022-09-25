# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

rails_env = ENV.fetch('RAILS_ENV', 'development')
environment rails_env
port ENV.fetch('PORT', 3000)

preload_app! unless rails_env == 'development'

plugin :tmp_restart

unless Puma.jruby? || Puma.windows? # workers supported
  workers Integer(ENV['WEB_CONCURRENCY'] || 2)

  before_fork do
    ActiveRecord::Base.connection_pool.disconnect!
  end

  on_worker_boot do
    ActiveRecord::Base.establish_connection
  end
end
