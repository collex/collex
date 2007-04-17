# Settings specified here will take precedence over those in config/environment.rb

#########################################################################################
# Custom environment for Staging. A blend of development and production environments.
# Caching is on as in production, but so are whiny nils, breakpoint_server, and debug_rjs
# as in development.
#########################################################################################

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Use a different logger for distributed setups
# config.logger        = SyslogLogger.new

# Enable the breakpoint server that script/breakpointer connects to
config.breakpoint_server = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_extensions         = true
config.action_view.debug_rjs                         = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.server_settings = { 
   :address => "localhost", 
   :port => 25, 
   :domain => "nines.org", 
} 
config.log_level = :info
