  # load all the site specific stuff
  config_file = File.join(Rails.root, "config", "site.yml")
  if File.exists?(config_file)
  	site_specific = YAML.load_file(config_file)

  	MAILER_INTERVAL_SECS = site_specific['daemons']['mailer_interval_secs']
  	USER_CONTENT_INTERVAL_SECS = site_specific['daemons']['user_content_interval_secs']
  	SESSION_CLEANER_INTERVAL_SECS = site_specific['daemons']['session_cleaner_interval_secs']
  
  	UPDATE_TASK = site_specific['update'] == nil ? '' : site_specific['update']
  	BLEEDING_EDGE = site_specific['bleeding_edge']
  	DISALLOW_RSS  = site_specific['disallow_rss'] == nil ? false : site_specific['disallow_rss']

	SVN_COLLEX = site_specific['svn']['url_collex']

	CACHE_DIR = "#{Rails.root}/cache"
  else
  	puts "***"
  	puts "*** Failed to load site configuration. Did you create config/site.yml?"
  	puts "***"
  end
