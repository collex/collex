# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

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

solr_url_for = { "staging" => "http://localhost:8989/solr" }

SOLR_URL = ENV["SOLR_URL_#{RAILS_ENV.upcase}"] || solr_url_for[RAILS_ENV] || "http://localhost:8983/solr"

puts "$$ Starting Rails with Solr URL: #{SOLR_URL}"

COLLEX_MANAGER = NinesCollectionManager.new
COLLEX_MANAGER.logger = RAILS_DEFAULT_LOGGER
CACHE_DIR = "#{RAILS_ROOT}/cache"
RELATORS = COLLEX_MANAGER.relators
DEFAULT_THUMBNAIL_IMAGE_PATH = "/images/harrington.gif"

ExceptionNotifier.exception_recipients = %w(esh6h@virginia.edu bethany@Virginia.EDU jamie@dang.com)
ExceptionNotifier.sender_address = %("Application Error" <technologies@nines.org>)
ExceptionNotifier.email_prefix = "[Collex] "

$KCODE = 'UTF8'

# "nines"
COLLEX_ENGINE_PARAMS = {
  :field_list => "archive,agent,date_label,genre,role_*,source,thumbnail,title,alternative,uri,url",
  :facet_fields => ['genre','archive','freeculture']
}
