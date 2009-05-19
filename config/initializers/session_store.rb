# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails_2_3_session',
  :secret      => 'f070bd62f32957762286d6f0cb75317d71083923144801ed87a5ae806eb8684c3adf6bba87263ca3a1025a706975adddad76a0fc0de167fa9adc3182ab4396ef'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
