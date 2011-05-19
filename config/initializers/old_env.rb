  # Include your application configuration 
  #ActiveRecord::Base.colorize_logging = false
  # require 'soap/wsdlDriver'
  # require 'rexml/document'
  # #require 'collex_engine'
  # require 'nines_collection_manager' # require this or get load errors in dev mode
  
  # load all the site specific stuff
  config_file = File.join(Rails.root, "config", "site.yml")
  if File.exists?(config_file)
  	site_specific = YAML.load_file(config_file)
	  SOLR_URL = site_specific['solr_url']
	  SOLR_CATALOG = site_specific['solr_catalog']

  	MAILER_INTERVAL_SECS = site_specific['daemons']['mailer_interval_secs']
  	USER_CONTENT_INTERVAL_SECS = site_specific['daemons']['user_content_interval_secs']
  	SESSION_CLEANER_INTERVAL_SECS = site_specific['daemons']['session_cleaner_interval_secs']
  
  	GOOGLE_ANALYTICS = site_specific['google_analytics']
	ANALYTICS_ID = site_specific['analytics_id']
  	UPDATE_TASK = site_specific['update'] == nil ? '' : site_specific['update']
  	BLEEDING_EDGE = site_specific['bleeding_edge']
  	DISALLOW_RSS  = site_specific['disallow_rss'] == nil ? false : site_specific['disallow_rss']
  	PROJECT_MANAGER_EMAIL = site_specific['project_manager_email']

	COLLEX_MANAGER = NinesCollectionManager.new
	COLLEX_MANAGER.logger = RAILS_DEFAULT_LOGGER
	CACHE_DIR = "#{Rails.root}/cache"
  else
  	puts "***"
  	puts "*** Failed to load site configuration. Did you create config/site.yml?"
  	puts "***"
  end
  
  puts "$$ Using Google Analytics: #{GOOGLE_ANALYTICS}"
