config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)

	MY_COLLEX_URL = site_specific['my_collex_url']
	SKIN = site_specific['skin']

	DEFAULT_THUMBNAIL_IMAGE_PATH = "/images/#{SKIN}/sm_site_image.gif"
	EXHIBIT_BUILDER_TODO_PATH = "/images/clicktoadd.jpg"
	PROGRESS_SPINNER_PATH = "/images/ajax_loader.gif"
	SPINNER_TIMEOUT_PATH = "/images/#{SKIN}/no_image.jpg"

	puts "$$ Starting Collex"
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end
