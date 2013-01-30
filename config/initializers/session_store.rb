require 'action_dispatch/middleware/session/dalli_store'
Rails.application.config.session_store :dalli_store, :memcache_server => 'localhost:11211', :namespace => 'sessions', :key => '_ffcrm_session', :expire_after => 3.days

