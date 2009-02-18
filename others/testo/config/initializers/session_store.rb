# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_testo_session',
  :secret      => '8d86ea4aa91cdef1c489df909592e8b5180984d9bde1d03ef6f8e0936e83ec0fa97fb409d40e3a35160fa78a66ba7259c5c98124170e502fac416c11e5cf08b2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
