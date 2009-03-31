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

# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
# require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  #config.frameworks -= [ :action_web_service, :active_record ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration 
#ActiveRecord::Base.colorize_logging = false
require 'soap/wsdlDriver'
require 'rexml/document'
require 'collex_engine'
require 'nines_collection_manager' # require this or get load errors in dev mode

solr_url_for = { "staging" => "http://localhost:8989/solr", "quandu_production" => "http://127.0.0.1:8080/nines-solr1.3", "quandu_staging" => "http://sds6.itc.virginia.edu:8080/nines-solr1.3" }

SOLR_URL = ENV["SOLR_URL_#{RAILS_ENV.upcase}"] || solr_url_for[RAILS_ENV] || "http://localhost:8983/solr"

puts "$$ Starting Rails with Solr URL: #{SOLR_URL}"

COLLEX_MANAGER = NinesCollectionManager.new
COLLEX_MANAGER.logger = RAILS_DEFAULT_LOGGER
CACHE_DIR = "#{RAILS_ROOT}/cache"
RELATORS = COLLEX_MANAGER.relators
DEFAULT_THUMBNAIL_IMAGE_PATH = "/images/harrington.gif"
EXHIBIT_BUILDER_TODO_PATH = "/images/clicktoadd.jpg"
PROGRESS_SPINNER_PATH = "/images/ajax_loader.gif"

ExceptionNotifier.exception_recipients = %w(dw6h@cms.mail.virginia.edu nick@performantsoftware.com paul@performantsoftware.com)
ExceptionNotifier.sender_address = %("Application Error" <technologies@nines.org>)
ExceptionNotifier.email_prefix = "[Collex] "

$KCODE = 'UTF8'

# "nines"
COLLEX_ENGINE_PARAMS = {
  # TODO: eventually leverage (an as yet undeveloped Solr feature) wildcarded field requests like "role_*"
  :field_list => ["archive","date_label","genre","role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL","source","image","thumbnail","text_url","title","alternative","uri","url", "exhibit_type", "license"],
  :facet_fields => ['genre','archive','freeculture']
}

#EXHIBIT_WHITE_LIST = %w{jamieorc nickl nowviskie jeromemcgann DWheeles mandellc erikhatcher aearhart cmw6s Laura_Nowocin wombat1 wombat2 wombat3 wombat4 wombat5}
#
## Configuration for Exhibits
#def exhibits_configuration_file
#  File.expand_path(File.dirname(__FILE__) + "/exhibits.yml")
#end
#def exhibits_configuration
#  YAML::load(ERB.new(IO.read(exhibits_configuration_file)).result)
#end
#EXHIBITS_CONF = exhibits_configuration[RAILS_ENV]
#puts "Exhibits Configuration: #{EXHIBITS_CONF.inspect}"

DEPLOYMENT_SERVER = "nines.org"
