config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)

	SITE_NAME = site_specific['site_name']
	SITE_NAME_TITLE = site_specific['site_name_title']
	MY_COLLEX = site_specific['my_collex']
	MY_COLLEX_URL = site_specific['my_collex_url']
	DEFAULT_FEDERATION = site_specific['default_federation']
	OTHER_FEDERATIONS = site_specific['other_federations']
	USER_CONTENT_CORE = site_specific['user_content_core']
	SKIN = site_specific['skin']
	ABOUT = { :link => site_specific['about']['link'], :label => site_specific['about']['label'] }
	ABOUT2 = { :link => site_specific['about']['link2'], :label => site_specific['about']['label2'] } if site_specific['about']['link2']
	FEDERATION_URLS = site_specific['federation_url']
	ZOTERO_GENRES = site_specific['zotero_genre']

	DEFAULT_THUMBNAIL_IMAGE_PATH = "/images/#{SKIN}/sm_site_image.gif"
	EXHIBIT_BUILDER_TODO_PATH = "/images/clicktoadd.jpg"
	PROGRESS_SPINNER_PATH = "/images/ajax_loader.gif"
	SPINNER_TIMEOUT_PATH = "/images/#{SKIN}/no_image.jpg"

	puts "$$ Starting #{SITE_NAME}"
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end
