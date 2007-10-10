##########################################################################
# Copyright 2007 Applied Research in Patacriticism
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

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
ActionMailer::Base.smtp_settings = { 
   :address => "localhost", 
   :port => 25, 
   :domain => "nines.org", 
} 
config.log_level = :info
