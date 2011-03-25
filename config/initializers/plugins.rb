# Define Plugins

config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)
	plugins = site_specific['plugins'] || {}
	plugins.delete_if { |key, value| value != true }
	COLLEX_PLUGINS = plugins

	plugins.each { |key, value|
		params = site_specific[key]
		params = {} if params == nil
		params[:name] = key
		plugins[key] = params
	}
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end
