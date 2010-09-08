# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_responds_to_parent_session',
  :secret      => '2f48e6928fe77e4b48455f87a47be103d3caa6501c2ff1f1494c9747dbfd8e3f36a8e403894f46c8fa00738609c09fe3751a9e3bf87aa642ed6a63d54e1bef75'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
