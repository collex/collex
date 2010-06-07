##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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

# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
 
  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  config.action_controller.session_store = :active_record_store

  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
  
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

#  config.gem 'mislav-will_paginate', :version => '~> 2.3.8', :lib => 'will_paginate',
#    :source => 'http://gems.github.com'
end

# Include your application configuration 
#ActiveRecord::Base.colorize_logging = false
require 'soap/wsdlDriver'
require 'rexml/document'
#require 'collex_engine'
require 'nines_collection_manager' # require this or get load errors in dev mode

# load all the site specific stuff
config_file = File.join(RAILS_ROOT, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)
	SOLR_URL = site_specific['solr_url']
	ExceptionNotifier.exception_recipients = site_specific['exception_notifier']['exception_recipients'].split(' ')
	ExceptionNotifier.sender_address = site_specific['exception_notifier']['sender_address']
	ExceptionNotifier.email_prefix = site_specific['exception_notifier']['email_prefix']

	ActionMailer::Base.smtp_settings[:address] = site_specific['smtp_settings']['address']
	ActionMailer::Base.smtp_settings[:port] = site_specific['smtp_settings']['port']
	ActionMailer::Base.smtp_settings[:domain] = site_specific['smtp_settings']['domain']
	ActionMailer::Base.smtp_settings[:user_name] = site_specific['smtp_settings']['user_name']
	ActionMailer::Base.smtp_settings[:password] = site_specific['smtp_settings']['password']
	ActionMailer::Base.smtp_settings[:authentication] = site_specific['smtp_settings']['authentication']

	MAILER_INTERVAL_SECS = site_specific['daemons']['mailer_interval_secs']
	USER_CONTENT_INTERVAL_SECS = site_specific['daemons']['user_content_interval_secs']

	GOOGLE_ANALYTICS = site_specific['google_analytics']
	JAVA_PATH = site_specific['java_path']
	SITE_NAME = site_specific['site_name']
	SITE_NAME_TITLE = site_specific['site_name_title']
	MY_COLLEX = site_specific['my_collex']
	MY_COLLEX_URL = site_specific['my_collex_url']
	DEFAULT_FEDERATION = site_specific['default_federation']
	CAN_INDEX = site_specific['can_index'] == nil ? false : site_specific['can_index']
	SKIN = site_specific['skin']
	UPDATE_TASK = site_specific['update'] == nil ? '' : site_specific['update']
	BLEEDING_EDGE = site_specific['bleeding_edge']
	DISALLOW_RSS  = site_specific['disallow_rss'] == nil ? false : site_specific['disallow_rss']
	PROJECT_MANAGER_EMAIL = site_specific['project_manager_email']
	ABOUT = { :link => site_specific['about']['link'], :label => site_specific['about']['label'] }
	ABOUT2 = { :link => site_specific['about']['link2'], :label => site_specific['about']['label2'] } if site_specific['about']['link2']
	
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end

puts "$$ Starting #{SITE_NAME} with Solr URL: #{SOLR_URL}"
#puts ExceptionNotifier.exception_recipients
#puts ExceptionNotifier.sender_address
#puts ExceptionNotifier.email_prefix
#puts ActionMailer::Base.smtp_settings[:address]
#puts ActionMailer::Base.smtp_settings[:port]
#puts ActionMailer::Base.smtp_settings[:domain]
#puts ActionMailer::Base.smtp_settings[:user_name]
#puts ActionMailer::Base.smtp_settings[:password]
#puts ActionMailer::Base.smtp_settings[:authentication]
puts "$$ Using Google Analytics: #{GOOGLE_ANALYTICS}"
if JAVA_PATH.length > 0
	puts "$$ Java path explicitly set to: #{JAVA_PATH}"
end

COLLEX_MANAGER = NinesCollectionManager.new
COLLEX_MANAGER.logger = RAILS_DEFAULT_LOGGER
CACHE_DIR = "#{RAILS_ROOT}/cache"
#RELATORS = COLLEX_MANAGER.relators
DEFAULT_THUMBNAIL_IMAGE_PATH = "/images/#{SKIN}/sm_site_image.gif"
EXHIBIT_BUILDER_TODO_PATH = "/images/clicktoadd.jpg"
PROGRESS_SPINNER_PATH = "/images/ajax_loader.gif"

$KCODE = 'UTF8'

