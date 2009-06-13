# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_fat_free_crm_session',
  :secret => 'f12e4853b601f05a5287dbe5cf340ed4fd4374b683b29c6ca6a1983555f5b07e5b6f28d416ca78a88087def507ea2d9d5a915cc00b95c90413d0ce0c8af2fecb'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
